import axios from "axios";
import {
  GoogleSignin,
  isSuccessResponse
} from "@react-native-google-signin/google-signin";
import * as SecureStore from "expo-secure-store";
import Constants from "expo-constants";
import { AuthClient, Http, Storage } from "./authClient";

const baseURL: string =
  (Constants.expoConfig?.extra as any)?.apiUrl ?? "http://localhost:3000";

const http: Http = {
  async request({ method, url, headers, data }) {
    const resp = await axios.request({
      baseURL,
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

export const authClient = new AuthClient(http, storage);

/**
 * Native Google sign-in. The ID token is exchanged with the CoLab server, which
 * validates it exactly as it does for the web client.
 */
export async function signInWithGoogle(): Promise<void> {
  const webClientId = await authClient.getGoogleClientId();
  if (!webClientId) {
    authClient.googleFailed(false);
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
    // SIGN_IN_CANCELLED
    authClient.googleFailed(e?.code === "-5" || e?.code === "SIGN_IN_CANCELLED");
  }
}
