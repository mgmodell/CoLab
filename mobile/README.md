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
