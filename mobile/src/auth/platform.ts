import axios from "axios";
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
