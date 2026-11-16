#!/usr/bin/env bash
# =============================================================================
#  Hard - Auth Token Forgery: Weak-Secret JWT   (REAL CoLab app, toolkit)
#  CoLab's reporting API issues an HS256 JSON Web Token at login and authorizes
#  the admin report purely on the token's `role` claim. The signing secret is a
#  weak dictionary word, so a holder of ANY issued token can crack the secret
#  offline and re-forge a token with role=admin. NOTHING is handed to the player:
#  they are given a low-privilege ANALYST account, log in to get their own token,
#  then crack + forge it. Embedded by lab-setup/patch_jwt.rb (real controller).
#
#  Solve path (hints walk it, penalised): log in -> read your JWT -> crack the
#  HS256 secret (jwt_tool + rockyou) -> forge role=admin -> GET the admin report.
# =============================================================================

token_provision() { return 0; }   # vuln is baked into the app image (patch_jwt.rb)

token_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "ACCOUNT.txt" \
"# You have been issued a low-privilege reporting-API account:
#     username: analyst
#     password: Analyst!2024
#
# CoLab reporting API (JWT-secured):
#     POST /api/reports/auth    {username,password}          -> { token: <JWT> }
#     GET  /api/reports/admin   (Authorization: Bearer <JWT>) -> admin-only report
#
# Your analyst token is NOT authorized for the admin report. Find a way to change
# that. (Tools for this room: curl, jwt_tool, jq.)"
}

register_challenge \
  id="hard-token" \
  title="Auth Token Forgery: Weak-Secret JWT - Hard" \
  diff="Hard" points="500" \
  owasp="A07:2021 Identification & Authentication Failures" \
  cvss="8.8 (AV:N/PR:L/S:U/C:H/I:H)" \
  slug="weak_jwt_admin_forge" \
  finding="CoLab Pentest Report - reporting-API JWT signed with a weak, guessable secret (forgeable role/identity)" \
  endpoint="POST /api/reports/auth  ·  GET /api/reports/admin (Bearer JWT)" \
  tools="curl,jwt_tool,jq" \
  scenario="CoLab's reporting API hands every client a JSON Web Token at login and trusts the 'role' claim inside it to authorize the admin report. You hold a low-privilege ANALYST account (analyst / Analyst!2024). The admin report is off-limits to you - unless the token's signature can be forged." \
  objective="Get your analyst JWT, recover the signing secret, forge a token claiming role=admin, and read the flag from GET /api/reports/admin." \
  remediation="Sign JWTs with a long random secret (or asymmetric keys) kept out of source; reject alg=none; authorize on a server-side session/role, never a client-presented claim; rotate secrets." \
  hints="Log in to the reporting API and look at the token it returns. A JWT is three dot-separated base64url parts - decode the middle (payload) and the first (header). What does 'role' say, and which algorithm (alg) signs it?
An HS256 token is signed with a SECRET; a weak secret can be cracked offline from any valid token. The toolkit ships jwt_tool and a wordlist:  jwt_tool <your-token> -C -d /usr/share/wordlists/rockyou.txt
With the key, forge a token that claims role=admin and sign it:  jwt_tool <your-token> -I -pc role -pv admin -S hs256 -p <key>  - then send it:  curl -H 'Authorization: Bearer <forged>' http://app:3000/api/reports/admin" \
  provision="token_provision" toolkit="token_toolkit" handler=""
