import { pickAuthHeaders, SAVED_CREDS_KEY, Storage, TOKEN_KEYS } from "./authClient";

/*
 * Platform-neutral counterparts of CONFIG.appendAuthHeaders and
 * CONFIG.storeRetrievedCredentials in the web client's ContextSlice.ts.
 */

export const appendAuthHeaders = (storage: Storage) => async (config: any) => {
  const raw = await storage.get(SAVED_CREDS_KEY);
  if (raw) {
    try {
      const saved = JSON.parse(raw);
      config.headers = config.headers ?? {};
      TOKEN_KEYS.forEach(key => {
        if (saved[key]) config.headers[key] = saved[key];
      });
    } catch {
      // ignore unreadable saved credentials
    }
  }
  return config;
};

export const storeRetrievedCredentials = (storage: Storage) => async (
  response: any
) => {
  const picked = pickAuthHeaders(response?.headers ?? {});
  if (picked) {
    await storage.set(SAVED_CREDS_KEY, JSON.stringify(picked));
  }
  return response;
};

export const attachAuthInterceptors = (
  instance: {
    interceptors: {
      request: { use: (fn: any) => any };
      response: { use: (fn: any) => any };
    };
  },
  storage: Storage
) => {
  instance.interceptors.request.use(appendAuthHeaders(storage));
  instance.interceptors.response.use(storeRetrievedCredentials(storage));
};
