import {
  AuthClient,
  Http,
  SAVED_CREDS_KEY,
  Storage
} from "../src/auth/authClient";

const hdrs = (expiry: number) => ({
  "access-token": "tok",
  "token-type": "Bearer",
  client: "c",
  uid: "a@b.com",
  expiry: String(expiry)
});
const future = () => Math.floor(Date.now() / 1000) + 3600;

const memStorage = (init: { [k: string]: string } = {}): Storage => {
  const m = { ...init };
  return {
    get: async k => m[k] ?? null,
    set: async (k, v) => {
      m[k] = v;
    },
    remove: async k => {
      delete m[k];
    }
  };
};

const httpReturning = (fn: (o: any) => any): Http => ({
  request: async o => fn(o)
});

describe("AuthClient", () => {
  it("signs in and persists credentials", async () => {
    const storage = memStorage();
    const client = new AuthClient(
      httpReturning(() => ({ status: 200, headers: hdrs(future()), data: {} })),
      storage
    );
    const seen: string[] = [];
    client.subscribe(s => seen.push(s.status));
    expect((await client.signIn("a@b.com", "pw")).status).toBe("signedIn");
    expect(seen).toEqual(["loading", "signedIn"]);
    expect(await storage.get(SAVED_CREDS_KEY)).toContain("tok");
  });

  it("errors on missing credentials without calling the server", async () => {
    const http = httpReturning(() => {
      throw new Error("no");
    });
    const state = await new AuthClient(http, memStorage()).signIn("", "");
    expect(state).toEqual({ status: "error", message: "missing_credentials" });
  });

  it("reports invalid credentials on 401", async () => {
    const client = new AuthClient(
      httpReturning(() => {
        throw { response: { status: 401 } };
      }),
      memStorage()
    );
    expect(await client.signIn("a@b.com", "bad")).toEqual({
      status: "error",
      message: "invalid_credentials"
    });
  });

  it("reports network errors", async () => {
    const client = new AuthClient(
      httpReturning(() => {
        throw new Error("down");
      }),
      memStorage()
    );
    expect((await client.signIn("a@b.com", "pw")).message).toBe("network");
  });

  it("restore is signedOut with nothing saved", async () => {
    const client = new AuthClient(httpReturning(() => ({})), memStorage());
    expect((await client.restore()).status).toBe("signedOut");
  });

  it("restore detects locally expired sessions", async () => {
    const storage = memStorage({
      [SAVED_CREDS_KEY]: JSON.stringify(hdrs(1))
    });
    const client = new AuthClient(httpReturning(() => ({})), storage);
    expect((await client.restore()).status).toBe("expired");
    expect(await storage.get(SAVED_CREDS_KEY)).toBeNull();
  });

  it("restore validates against the server", async () => {
    const storage = memStorage({
      [SAVED_CREDS_KEY]: JSON.stringify(hdrs(future()))
    });
    const ok = new AuthClient(
      httpReturning(() => ({ status: 200, headers: {}, data: { logged_in: true } })),
      storage
    );
    expect((await ok.restore()).status).toBe("signedIn");
    const rejected = new AuthClient(
      httpReturning(() => ({ status: 200, headers: {}, data: { logged_in: false } })),
      storage
    );
    expect((await rejected.restore()).status).toBe("expired");
  });

  it("signs out locally even if the server call fails", async () => {
    const storage = memStorage({
      [SAVED_CREDS_KEY]: JSON.stringify(hdrs(future()))
    });
    const client = new AuthClient(
      httpReturning(() => {
        throw new Error("down");
      }),
      storage
    );
    expect((await client.signOut()).status).toBe("signedOut");
    expect(await storage.get(SAVED_CREDS_KEY)).toBeNull();
  });

  it("signs in with a Google ID token via /auth/validate", async () => {
    const storage = memStorage();
    const calls: any[] = [];
    const client = new AuthClient(
      httpReturning(o => {
        calls.push(o);
        return { status: 200, headers: hdrs(future()), data: { message: "ok" } };
      }),
      storage
    );
    expect((await client.signInWithGoogle("idtok")).status).toBe("signedIn");
    expect(calls[0].url).toBe("/auth/validate.json");
    expect(calls[0].data).toEqual({ id_token: "idtok" });
    expect(await storage.get(SAVED_CREDS_KEY)).toContain("tok");
  });

  it("errors when the server returns no credentials for a Google token", async () => {
    const client = new AuthClient(
      httpReturning(() => ({ status: 200, headers: {}, data: { message: "no login yet" } })),
      memStorage()
    );
    expect(await client.signInWithGoogle("idtok")).toEqual({
      status: "error",
      message: "google_failed"
    });
  });

  it("treats a cancelled Google flow as signed out, not an error", () => {
    const client = new AuthClient(httpReturning(() => ({})), memStorage());
    client.googleFailed(true);
    expect(client.getState().status).toBe("signedOut");
    client.googleFailed(false);
    expect(client.getState().message).toBe("google_failed");
  });

  it("reads the Google client id from the server lookups", async () => {
    const client = new AuthClient(
      httpReturning(() => ({
        status: 200,
        headers: {},
        data: { lookups: { oauth_ids: { google: "gid" } } }
      })),
      memStorage()
    );
    expect(await client.getGoogleClientId()).toBe("gid");
  });
});
