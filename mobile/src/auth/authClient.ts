/*
 * Platform-neutral authentication layer. It speaks the same devise_token_auth
 * contract as the web client (app/javascript/components/infrastructure/
 * ContextSlice.ts): POST /auth/sign_in, the access-token/client/uid/expiry
 * headers, and GET /endpoints.json for the logged_in check.
 */

export type AuthStatus =
  | "signedOut"
  | "loading"
  | "signedIn"
  | "expired"
  | "error";

export interface AuthState {
  status: AuthStatus;
  message?: string;
}

export type AuthHeaders = { [key: string]: string };

// Same keys as CONFIG.tokenFormat in the web client
export const TOKEN_KEYS = [
  "access-token",
  "token-type",
  "client",
  "expiry",
  "uid"
] as const;

export const SAVED_CREDS_KEY = "colab_authHeaders";

export interface Storage {
  get(key: string): Promise<string | null>;
  set(key: string, value: string): Promise<void>;
  remove(key: string): Promise<void>;
}

export interface HttpResponse {
  status: number;
  headers: { [key: string]: string };
  data: any;
}

export interface Http {
  request(opts: {
    method: "GET" | "POST" | "DELETE";
    url: string;
    headers?: AuthHeaders;
    data?: any;
  }): Promise<HttpResponse>;
}

export const pickAuthHeaders = (headers: {
  [key: string]: string;
}): AuthHeaders | null => {
  const picked: AuthHeaders = {};
  let found = false;
  TOKEN_KEYS.forEach(key => {
    const val = headers[key] ?? headers[key.toLowerCase()];
    if (val) {
      picked[key] = val;
      found = true;
    }
  });
  return found ? picked : null;
};

export const isExpired = (headers: AuthHeaders, now = Date.now()): boolean => {
  const expiry = parseInt(headers["expiry"], 10) * 1000;
  return !isNaN(expiry) && expiry <= now;
};

export class AuthClient {
  private state: AuthState = { status: "signedOut" };
  private listeners: Array<(s: AuthState) => void> = [];

  constructor(
    private http: Http,
    private storage: Storage,
    private now: () => number = Date.now
  ) {}

  getState(): AuthState {
    return this.state;
  }

  subscribe(fn: (s: AuthState) => void): () => void {
    this.listeners.push(fn);
    return () => {
      this.listeners = this.listeners.filter(l => l !== fn);
    };
  }

  private set(state: AuthState) {
    this.state = state;
    this.listeners.forEach(l => l(state));
  }

  private async saved(): Promise<AuthHeaders | null> {
    const raw = await this.storage.get(SAVED_CREDS_KEY);
    if (!raw) return null;
    try {
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  private async persist(headers: { [key: string]: string }) {
    const picked = pickAuthHeaders(headers);
    if (picked) {
      await this.storage.set(SAVED_CREDS_KEY, JSON.stringify(picked));
    }
  }

  async signIn(email: string, password: string): Promise<AuthState> {
    if (!email || !password) {
      this.set({ status: "error", message: "missing_credentials" });
      return this.state;
    }
    this.set({ status: "loading" });
    try {
      const resp = await this.http.request({
        method: "POST",
        url: "/auth/sign_in",
        data: { email, password }
      });
      if (resp.data?.error || !pickAuthHeaders(resp.headers)) {
        this.set({ status: "error", message: "invalid_credentials" });
      } else {
        await this.persist(resp.headers);
        this.set({ status: "signedIn" });
      }
    } catch (e: any) {
      const code = e?.response?.status ?? e?.status;
      this.set({
        status: "error",
        message: code === 401 ? "invalid_credentials" : "network"
      });
    }
    return this.state;
  }

  /** Restore a session at app start, validating against the server. */
  async restore(): Promise<AuthState> {
    const headers = await this.saved();
    if (!headers) {
      this.set({ status: "signedOut" });
      return this.state;
    }
    if (isExpired(headers, this.now())) {
      await this.storage.remove(SAVED_CREDS_KEY);
      this.set({ status: "expired" });
      return this.state;
    }
    this.set({ status: "loading" });
    try {
      const resp = await this.http.request({
        method: "GET",
        url: "/endpoints.json",
        headers
      });
      if (resp.data?.logged_in) {
        await this.persist(resp.headers);
        this.set({ status: "signedIn" });
      } else {
        await this.storage.remove(SAVED_CREDS_KEY);
        this.set({ status: "expired" });
      }
    } catch (e: any) {
      const code = e?.response?.status ?? e?.status;
      if (code === 401) {
        await this.storage.remove(SAVED_CREDS_KEY);
        this.set({ status: "expired" });
      } else {
        this.set({ status: "error", message: "network" });
      }
    }
    return this.state;
  }

  async signOut(): Promise<AuthState> {
    const headers = await this.saved();
    try {
      if (headers) {
        await this.http.request({
          method: "DELETE",
          url: "/auth/sign_out",
          headers
        });
      }
    } catch {
      // Local sign out proceeds regardless
    }
    await this.storage.remove(SAVED_CREDS_KEY);
    this.set({ status: "signedOut" });
    return this.state;
  }
}
