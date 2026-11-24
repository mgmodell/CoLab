import { PushClient, serverPlatform } from "../src/push/pushClient";
import { ROUTES } from "../src/auth/routes";

const headers = { "access-token": "t", client: "c", uid: "u" };

describe("PushClient", () => {
  it("maps OS to server platform", () => {
    expect(serverPlatform("ios")).toBe("apple");
    expect(serverPlatform("android")).toBe("google");
    expect(serverPlatform("web")).toBeNull();
  });

  it("registers then unregisters the token", async () => {
    const calls: any[] = [];
    const client = new PushClient(
      { request: async o => (calls.push(o), { status: 200, headers: {}, data: {} }) },
      async () => headers
    );
    expect(await client.register("google", "tok", "Pixel")).toBe(true);
    await client.unregister();
    expect(calls[0]).toMatchObject({ method: "POST", url: ROUTES.pushDevices, headers,
      data: { platform: "google", token: "tok", name: "Pixel" } });
    expect(calls[1]).toMatchObject({ method: "DELETE", data: { token: "tok" } });
  });

  it("does not register when signed out", async () => {
    const client = new PushClient(
      { request: async () => { throw new Error("no"); } },
      async () => null
    );
    expect(await client.register("apple", "tok")).toBe(false);
  });
});
