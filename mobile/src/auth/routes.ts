/*
 * Server paths used by the mobile client. Keep these in sync with
 * config/routes.rb; this is the only place paths should be written.
 * The web client avoids hard-coding by receiving `endpoints_path` from the
 * server-rendered layout, which a native app can't do.
 */

// config/routes.rb: scope 'infra' do ... get 'endpoints' ... end
const INFRA = "/infra";

// config/routes.rb: mount_devise_token_auth_for 'User', at: 'auth'
const AUTH = "/auth";

export const ROUTES = {
  /** home#endpoints: logged_in flag, lookups (incl. oauth_ids) and endpoint map */
  endpoints: `${INFRA}/endpoints.json`,
  /** devise_token_auth sessions */
  signIn: `${AUTH}/sign_in`,
  signOut: `${AUTH}/sign_out`,
  /** users/omniauth_callbacks#validate (Google ID token exchange) */
  googleValidate: `${AUTH}/validate.json`,
  /** push_devices#create / #destroy (native push token registration) */
  pushDevices: `/api-backend/push_devices`
} as const;
