import { AuthHeaders, Http } from "../auth/authClient";
import { ROUTES } from "../auth/routes";

/*
 * Platform-neutral push-token registration. The server (PushDevicesController)
 * expects platform "apple" (APNs token) or "google" (FCM token).
 */

export type PushPlatform = "apple" | "google";

export const serverPlatform = (os: string): PushPlatform | null =>
  os === "ios" ? "apple" : os === "android" ? "google" : null;

export class PushClient {
  private registeredToken: string | null = null;

  constructor(
    private http: Http,
    private getAuthHeaders: () => Promise<AuthHeaders | null>
  ) {}

  /** Register this device's token for the signed-in user. Returns success. */
  async register(
    platform: PushPlatform,
    token: string,
    name?: string
  ): Promise<boolean> {
    const headers = await this.getAuthHeaders();
    if (!headers || !token) return false;
    try {
      await this.http.request({
        method: "POST",
        url: ROUTES.pushDevices,
        headers,
        data: { platform, token, name }
      });
      this.registeredToken = token;
      return true;
    } catch {
      return false;
    }
  }

  /** Remove this device's token from the user (call before signing out). */
  async unregister(): Promise<void> {
    const token = this.registeredToken;
    if (!token) return;
    const headers = await this.getAuthHeaders();
    if (!headers) return;
    try {
      await this.http.request({
        method: "DELETE",
        url: ROUTES.pushDevices,
        headers,
        data: { token }
      });
    } catch {
      // Sign out proceeds regardless
    }
    this.registeredToken = null;
  }
}
