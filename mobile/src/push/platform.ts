import { Platform } from "react-native";
import * as Notifications from "expo-notifications";
import * as Device from "expo-device";
import { authClient, http } from "../auth/platform";
import { PushClient, serverPlatform } from "./pushClient";

export const pushClient = new PushClient(http, () => authClient.getAuthHeaders());

// Present notifications received while the app is open the standard way
// (banner + sound on iOS, heads-up notification on Android).
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowBanner: true,
    shouldShowList: true,
    shouldPlaySound: true,
    shouldSetBadge: false
  })
});

/**
 * Ask permission, create the Android channel and register the native
 * (APNs / FCM) device token with the CoLab server. Call once signed in.
 */
export async function registerForPush(): Promise<boolean> {
  const platform = serverPlatform(Platform.OS);
  if (!platform || !Device.isDevice) return false;

  if (Platform.OS === "android") {
    await Notifications.setNotificationChannelAsync("default", {
      name: "CoLab",
      importance: Notifications.AndroidImportance.DEFAULT
    });
  }

  let { status } = await Notifications.getPermissionsAsync();
  if (status !== "granted") {
    ({ status } = await Notifications.requestPermissionsAsync());
  }
  if (status !== "granted") return false;

  const { data } = await Notifications.getDevicePushTokenAsync();
  return pushClient.register(platform, String(data), Device.deviceName ?? undefined);
}
