#!/usr/bin/env bash
# =============================================================================
#  Hard — Insecure Deserialization: Session Cookie
#  Teaching room. The session cookie is an unsigned base64 blob the server
#  trusts. Tamper the deserialized object to escalate to admin and read the flag.
# =============================================================================

deser_provision() {
  local id="$1"
  # starting (student) session cookie handed to the player
  mw_b64e '{"uid":1001,"role":"student"}' > "$(pv_target_dir "$id")/student.cookie"
}

deser_handle() {
  [[ "$REQ_PATH" == /api/session/whoami ]] || { mw_resp "404 Not Found" '{"error":"unknown route"}'; return; }
  local c dec low; c="$(mw_cookie session)"
  if [[ -z "$c" ]]; then mw_resp "401 Unauthorized" '{"error":"no session cookie"}'; return; fi
  dec="$(mw_b64d "$c")"
  low="$(printf '%s' "$dec" | tr '[:upper:]' '[:lower:]')"
  if [[ "$low" == *'"role":"admin"'* || "$low" == *'role: admin'* || "$low" == *'!ruby/object'* ]]; then
    mw_resp "200 OK" "{\"uid\":1,\"role\":\"admin\",\"admin_secret\":\"$(flags_plaintext hard-deser)\"}"
  else
    mw_resp "200 OK" "{\"decoded\":\"$dec\",\"role\":\"student\"}"
  fi
}

deser_toolkit() {
  local id="$1" start; start="$(cat "$(pv_target_dir "$id")/student.cookie" 2>/dev/null)"
  toolkit_install_helper "$id" "cookie.txt" \
"# Your current (student) session cookie value:
$start

# Decode it:   echo '$start' | base64 -d
# Forge admin: printf '%s' '{\"uid\":1,\"role\":\"admin\"}' | base64
# Then:        ./colab-http GET /api/session/whoami -b \"session=<forged>\""
  toolkit_install_helper "$id" "forge-cookie.sh" \
"#!/usr/bin/env bash
# Encode a JSON session blob to a cookie value.  usage: ./forge-cookie.sh '{\"uid\":1,\"role\":\"admin\"}'
printf '%s' \"\${1:-{\\\"uid\\\":1,\\\"role\\\":\\\"admin\\\"}}\" | base64 | tr -d '\n'; echo"
}

register_challenge \
  id="hard-deser" \
  title="Insecure Deserialization: Session Cookie - Hard" \
  diff="Hard" points="500" penalty="70" \
  owasp="A08:2021 Software & Data Integrity Failures" \
  cvss="8.1 (AV:N/PR:L)" \
  slug="marshal_cookie_gadget" \
  finding="Teaching room — session integrity was verified in the real engagement" \
  endpoint="GET /api/session/whoami  (Cookie: session=<base64>)" \
  tools="curl,httpie,base64" \
  scenario="The app stores the session as a base64-encoded, UNSIGNED serialized object in the 'session' cookie and deserializes it on every request without integrity checks. Your working dir has your current student cookie." \
  objective="Tamper the serialized session so the server deserializes you as an admin, then read the admin secret." \
  remediation="Sign & verify session data (HMAC); never deserialize untrusted input; prefer opaque server-side sessions." \
  hints="Look at cookie.txt in your working dir — base64-decode it to see the object the server trusts.
Change role to admin, re-encode, and send it back as the session cookie.
./forge-cookie.sh '{\"uid\":1,\"role\":\"admin\"}'  then  ./colab-http GET /api/session/whoami -b \"session=<value>\"" \
  provision="deser_provision" toolkit="deser_toolkit" handler="deser_handle"
