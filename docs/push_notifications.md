# Native push notifications (iOS & Android)

CoLab uses the [action_push_native](https://github.com/rails/action_push_native)
gem. Push notifications are currently sent for:

* Weekly check-in / pending-activity reminders (`AdministrativeMailer.send_reminder_emails`)
* Bingo! candidate review completed (`AdministrativeMailer.notify_availability`)

Users with no registered device are simply skipped. Credentials are configured
in `config/push.yml` from environment variables. After pulling this change run
`bundle install` and `rails db:migrate`.

## Registering a device

The native app, once the user is signed in, calls (JSON, with the usual auth headers):

    POST   /api-backend/push_devices   {"platform": "apple" | "google", "token": "<device token>", "name": "<optional>"}
    DELETE /api-backend/push_devices   {"token": "<device token>"}   (e.g. on sign-out)

## iOS (APNs)

1. In the Apple Developer portal, enable the **Push Notifications** capability for your App ID.
2. Create an APNs **Auth Key** (Keys → +, tick Apple Push Notifications service). Download the `.p8` file once.
3. Note the **Key ID** and your **Team ID**, plus the app **Bundle ID**.
4. Set environment variables:
   * `APNS_KEY_ID` – Key ID
   * `APNS_ENCRYPTION_KEY` – contents of the `.p8` file (newlines may be written as `\n`)
   * `APPLE_TEAM_ID` – Team ID
   * `APPLE_BUNDLE_ID` – Bundle ID (the APNs topic)
5. In Xcode add the *Push Notifications* capability, request permission with
   `UNUserNotificationCenter`, call `registerForRemoteNotifications()`, and send the
   hex device token to the endpoint above with `platform: "apple"`.
6. Development builds use the sandbox APNs environment (`development` in `config/push.yml`); TestFlight/App Store builds use `production`.

## Android (Firebase Cloud Messaging)

1. Create a project in the [Firebase console](https://console.firebase.google.com) and add your Android app (package name).
2. Add `google-services.json` to the app and the Firebase Messaging SDK dependency.
3. In Project settings → Service accounts, **Generate new private key** (JSON).
4. Set environment variables:
   * `FCM_PROJECT_ID` – Firebase project id
   * `FCM_SERVICE_ACCOUNT_JSON` – the full contents of the service-account JSON
5. In the app, obtain the token with `FirebaseMessaging.getInstance().token` (and in `onNewToken`)
   and send it to the endpoint above with `platform: "google"`. On Android 13+ request the
   `POST_NOTIFICATIONS` runtime permission.

## Mobile app (`mobile/`, React Native / Expo)

The app uses `expo-notifications` and `expo-device`:

* After sign-in it asks for notification permission, creates the Android `default`
  channel, obtains the native APNs/FCM device token (`getDevicePushTokenAsync`) and
  registers it with `POST /api-backend/push_devices`; sign-out calls `DELETE`.
* Foreground notifications are shown as a standard banner (iOS) / heads-up (Android);
  background ones are presented by the OS.
* iOS: the `expo-notifications` config plugin adds the `aps-environment` entitlement;
  build with an App ID that has Push Notifications enabled (`npx expo prebuild`, then run on a real device).
* Android: download `google-services.json` from Firebase and set
  `GOOGLE_SERVICES_FILE=/absolute/path/google-services.json` when building.
* Push only works on physical devices, not simulators/emulators without Play Services.
