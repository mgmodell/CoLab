# CoLab Mobile (React Native / Expo)

Student-facing mobile client. This first slice supports logging in.

The auth layer (`src/auth/authClient.ts`) is platform neutral and uses the same
devise_token_auth contract as the web client (`/auth/sign_in`, token headers,
`/infra/endpoints.json`; all paths live in `src/auth/routes.ts`). Auth states: `signedOut`, `loading`, `signedIn`, `expired`, `error`.

`mobile/` is its own **npm** project (the repo root uses Yarn 4, which refuses to
run in a nested directory it doesn't manage). Use `npm`, not `yarn`, in here:

- `npm ci --legacy-peer-deps` – install (first time; use `npm install --legacy-peer-deps` to change deps)
- `npm test` – unit tests
- `npm run typecheck`
- `npm run android` / `npm run ios` – build and run on an emulator/simulator. These need the Android SDK / Xcode and an emulator, which the containers do not have, so **run them on the host**, not in the dev container (see "Running on a Mac")
- `E2E_EMAIL=… E2E_PASSWORD=… npm run e2e` – [Maestro](https://maestro.mobile.dev) flows in `.maestro/`
  (same flows run on iOS simulator and Android emulator)

## Running on a Mac (Apple silicon or Intel)

The Android emulator container needs `/dev/kvm`, which Podman on macOS doesn't
provide, so on a Mac the emulator/simulator runs on the **host** and only the
backend runs in the container.

1. Install on the host: Node 22, Xcode (iOS), and Android Studio (Android SDK +
   an emulator image; create an AVD in Device Manager).
2. Start the backend from the dev container (`bin/rails server -b 0.0.0.0`, port
   3000 is already published to the host) and seed a login:
   `bin/rails mobile:seed_e2e` (mobile_e2e@example.com / password).
3. On the host, in `mobile/`:

       npm ci --legacy-peer-deps
       export ANDROID_HOME="$HOME/Library/Android/sdk"
       export PATH="$ANDROID_HOME/platform-tools:$PATH"
       # start the AVD from Android Studio first, then:
       COLAB_API_URL=http://10.0.2.2:3000 npm run android   # Android emulator
       COLAB_API_URL=http://localhost:3000 npm run ios      # iOS simulator

   `10.0.2.2` is how the Android emulator reaches the host's localhost.
4. Maestro on the host (`brew install maestro`, or the installer at
   <https://maestro.mobile.dev>): `E2E_EMAIL=mobile_e2e@example.com E2E_PASSWORD=password npm run e2e`.

`scripts/e2e_ios.sh` automates the iOS part of this.

### Troubleshooting: "Unsupported class file major version 69"

Gradle is running on JDK 25, which the Gradle bundled with React Native 0.79
can't read. `mobile/mise.toml` pins `java = "temurin-17"`, and `npm run android`
installs it with mise and uses it automatically (no mise? it falls back to a JDK
17/21 found by `/usr/libexec/java_home`). If it still fails, run
`cd android && ./gradlew --stop` and retry.

### Troubleshooting: "The emulator (...) quit before it finished opening"

`expo run:android` only launches the AVD; the failure is in the emulator itself.
Start it by hand to see the real error:

    $ANDROID_HOME/emulator/emulator @Medium_Phone_API_37.0 -verbose

Common causes:

- **Wrong CPU architecture.** On Apple silicon the AVD must use an `arm64-v8a`
  system image. An `x86_64` image will exit immediately. In Android Studio's
  Device Manager, delete the AVD and create a new one from an arm64 image.
- **Missing or old emulator.** Update *Android Emulator* and the system image in
  SDK Manager > SDK Tools. A brand-new preview API level (such as 37) is the most
  likely to be flaky; try a stable image (e.g. API 35 or 36).
- **Not enough disk or RAM.** The emulator needs several GB free.
- **Stale state.** Run it once with `-wipe-data`, or start it from Android
  Studio's Device Manager first, wait for the home screen, then run
  `npm run android` so Expo finds the running device.

You can also ignore the `npm audit` and `fsevents` warnings during install; they
come from build tooling and don't affect the app.

## End-to-end tests in the containers (x86_64 Linux with /dev/kvm only)

The Maestro flows need an emulator and a seeded backend. Both are wired into the
Podman setups; `mobile/scripts/e2e_android.sh` does the work (installs a JDK,
the Android SDK and Maestro into the mise volume on first use, seeds the
`mobile:seed_e2e` user, starts Rails, builds and installs the debug APK, runs
`maestro test`).

**Emulator requirements:** the `android` service (a `budtmo/docker-android`
image, behind the `mobile` compose profile) needs `/dev/kvm`, so an x86_64 Linux
host (or a Podman machine with nested virtualisation). It will not run on Apple
silicon. Watch the emulator at <http://localhost:6081>.

**Test environment (Podman)**

    ./run_tests.sh -m

Starts the emulator, creates the test DB if needed, and runs the Android flows.
JUnit output goes to `reports/mobile_e2e.xml`.

**Dev container**

    # on the host
    podman compose -f containers/dev_env/docker-compose.yml --profile mobile up -d android
    # inside the dev container
    mobile/scripts/e2e_android.sh

This seeds `mobile_e2e@example.com` / `password` (override with `E2E_EMAIL` /
`E2E_PASSWORD`) into the development database.

**iOS:** simulators only run on macOS and cannot run in a Linux container. With
the backend published on `localhost:3000`, run `mobile/scripts/e2e_ios.sh` on the
Mac host. CI builds the iOS app on a macOS runner.

## Google sign-in

The login screen offers "Continue with Google" using
`@react-native-google-signin/google-signin` (needs a dev build / `expo prebuild`,
not Expo Go). The app gets the Google web client id from the server
(`lookups.oauth_ids.google`, same as the web UI), obtains an ID token natively,
and posts it to `/auth/validate.json`, the endpoint the web client uses.

Setup: in Google Cloud create an Android client (package `com.mmp.colab`,
with your signing SHA-1) and an iOS client, then replace the
`REPLACE_WITH_IOS_CLIENT_ID` placeholders in `app.json`. The native account
chooser can't be automated by Maestro, so the e2e flows only check that the
button is present.

### Troubleshooting: "Google sign-in failed"

The error line now shows a detail underneath (and `console.warn` logs it; see
`npx react-native log-android` or `adb logcat *:S ReactNativeJS:V`). Match it to:

- `no_client_id` / "server did not provide a Google client id": the app
  reached the server but `credentials.google.client_id` is unset, or `apiUrl` is
  wrong.
- `10` / `DEVELOPER_ERROR`: the Google Cloud setup doesn't match the build.
  - The **Android** OAuth client is never put in `app.json`. Google matches it
    on the app's package name (`org.mgmodell.colab`) plus the **SHA-1 of the
    keystore that signed the build**. For `npm run android` that is the debug
    keystore: `keytool -list -v -keystore mobile/android/app/debug.keystore -alias androiddebugkey -storepass android -keypass android`
    (or just run `mobile/scripts/signing_report.sh`, which also uses the right JDK; a bare
    `./gradlew signingReport` fails without `ANDROID_HOME`).
    Paste that SHA-1 into the Android client. It can take several minutes to propagate.
  - The ID token is requested for the **Web** client id, which the server
    publishes from `credentials.google.client_id`. That must be the Web
    application client (the same one the web UI uses), in the **same Google Cloud
    project** as the Android client.
- `12500` / `SIGN_IN_FAILED`, or `PLAY_SERVICES_NOT_AVAILABLE`: the emulator image
  needs Google Play (pick a "Google Play" system image) and a signed-in Google
  account (Settings > Passwords & accounts).
- `server: ...` / `server request failed (...)`: Google worked, but
  `/auth/validate.json` rejected the token (e.g. the account isn't allowed, or the
  server can't reach googleapis.com).

### Troubleshooting: iOS `pod install` "Swift pods cannot yet be integrated as static libraries"

Google Sign-In's pods (`AppCheckCore`, ...) are Swift and must build as
frameworks. `app.json` enables this with the `expo-build-properties` plugin
(`ios.useFrameworks: "static"`). After pulling this change, regenerate the native
project: `rm -rf ios && npx expo prebuild --platform ios --clean`, then
`npm run ios`.

## Tasks

After sign-in the app lists the user's available tasks (the task list URL comes from
`/infra/endpoints.json` as `endpoints.home.taskListUrl`; same data as the web `TaskList`). Selecting one shows a stub page with an
"Open in CoLab" button that deep-links to the activity on the website.
Native components are used (PrimeReact does not run in React Native); the
platform-neutral data layer lives in `src/tasks/tasks.ts`.
