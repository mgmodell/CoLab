# CoLab Mobile (React Native / Expo)

Student-facing mobile client. This first slice supports logging in.

The auth layer (`src/auth/authClient.ts`) is platform neutral and uses the same
devise_token_auth contract as the web client (`/auth/sign_in`, token headers,
`/endpoints.json`). Auth states: `signedOut`, `loading`, `signedIn`, `expired`, `error`.

- `yarn install && yarn test` – unit tests
- `yarn typecheck`
- `yarn android` / `yarn ios` – build and run
- `E2E_EMAIL=… E2E_PASSWORD=… yarn e2e` – [Maestro](https://maestro.mobile.dev) flows in `.maestro/`
  (same flows run on iOS simulator and Android emulator)

## End-to-end tests in the containers

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
