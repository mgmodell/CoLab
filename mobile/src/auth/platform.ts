import axios from "axios";
import {
  GoogleSignin,
  isSuccessResponse
} from "@react-native-google-signin/google-signin";
import * as SecureStore from "expo-secure-store";
import Constants from "expo-constants";
import { AuthClient, Http, Storage } from "./authClient";
import { attachAuthInterceptors } from "./interceptors";

export const apiUrl: string =
  (Constants.expoConfig?.extra as any)?.apiUrl ?? "http://localhost:3000";

// Configure the global axios instance so any module can call axios directly.
axios.defaults.baseURL = apiUrl;
axios.defaults.headers.common["Accept"] = "application/json";

const http: Http = {
  async request({ method, url, headers, data }) {
    const resp = await axios.request({
      method,
      url,
      headers: { Accept: "application/json", ...headers },
      data
    });
    return {
      status: resp.status,
      headers: resp.headers as any,
      data: resp.data
    };
  }
};

const storage: Storage = {
  get: key => SecureStore.getItemAsync(key),
  set: (key, value) => SecureStore.setItemAsync(key, value),
  remove: key => SecureStore.deleteItemAsync(key)
};

// Same model as the web client (ContextSlice.ts): axios adds the saved auth
// headers to every request and stores the rotated ones from every response.
attachAuthInterceptors(axios, storage);

export const authClient = new AuthClient(http, storage);

/**
 * Native Google sign-in. The ID token is exchanged with the CoLab server, which
 * validates it exactly as it does for the web client.
 */
export async function signInWithGoogle(): Promise<void> {
  const webClientId = await authClient.getGoogleClientId();
  if (!webClientId) {
    console.warn(
      "[google] server returned no lookups.oauth_ids.google; check credentials.google.client_id and apiUrl"
    );
    authClient.googleFailed(false, "no_client_id");
    return;
  }
  try {
    GoogleSignin.configure({
      webClientId,
      iosClientId: (Constants.expoConfig?.extra as any)?.googleIosClientId
    });
    await GoogleSignin.hasPlayServices();
    const response = await GoogleSignin.signIn();
    if (isSuccessResponse(response) && response.data.idToken) {
      await authClient.signInWithGoogle(response.data.idToken);
    } else {
      authClient.googleFailed(true);
    }
  } catch (e: any) {
    console.warn("[google] sign-in error", e?.code, e?.message);
    const cancelled = e?.code === "-5" || e?.code === "SIGN_IN_CANCELLED";
    authClient.googleFailed(cancelled, `${e?.code ?? "unknown"}: ${e?.message ?? ""}`);
  }
}
