#!/usr/bin/env bash
# =============================================================================
#  Medium — SQL Injection: Search Endpoint
#  Teaching room (classic UNION-based SQLi). The `q` param is concatenated into
#  a query; a UNION SELECT against the secrets table returns the flag.
# =============================================================================

sqli_provision() { :; }   # stateless mock DB

sqli_handle() {
  [[ "$REQ_PATH" == /api/search ]] || { mw_resp "404 Not Found" '{"error":"unknown route"}'; return; }
  local q ql; q="$(mw_query q)"
  # minimal URL decode so payloads read naturally
  q="${q//+/ }"; q="${q//%27/\'}"; q="${q//%20/ }"; q="${q//%2d/-}"; q="${q//%2D/-}"; q="${q//%3d/=}"
  ql="$(printf '%s' "$q" | tr '[:upper:]' '[:lower:]')"
  if [[ "$ql" == *union*select* && ( "$ql" == *secret* || "$ql" == *flag* ) ]]; then
    mw_resp "200 OK" "[{\"leaked\":\"$(flags_plaintext med-sqli)\"}]"
  elif [[ "$ql" == *"' or '1'='1"* || "$ql" == *" or 1=1"* || "$ql" == *"--"* || "$ql" == *"'"* ]]; then
    mw_resp "200 OK" '[{"course":"Algebra I"},{"course":"Biology"},{"course":"AP Chemistry"},{"course":"__seed_internal"}]'
  else
    mw_resp "200 OK" "[{\"course\":\"(matches for: ${q})\"}]"
  fi
}

# Small cheatsheet helper installed into the working dir.
sqli_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "sqli-cheatsheet.txt" \
"# SQLi cheatsheet for /api/search?q=
# probe an injection point:
colab-http GET \"/api/search?q=x' OR '1'='1\"
# enumerate via UNION (unknown column count -> try until it lines up):
colab-http GET \"/api/search?q=x' UNION SELECT flag FROM secrets-- \"
# NOTE: sqlmap needs a live HTTP URL; against this offline mock, inject by hand
#       through ./colab-http (same logic, no socket)."
}

register_challenge \
  id="med-sqli" \
  title="SQL Injection: Search Endpoint - Medium" \
  diff="Medium" points="250" penalty="35" \
  owasp="A03:2021 Injection (SQLi)" \
  cvss="8.6 (AV:N/PR:N)" \
  slug="union_select_secrets" \
  finding="Teaching room — SQLi was tested and hardened in the real engagement" \
  endpoint="GET /api/search?q=..." \
  tools="curl,httpie,sqlmap,jq" \
  scenario="The course search builds its SQL by string-concatenating the q parameter. A separate secrets table in the same database holds an internal value. Classic UNION territory." \
  objective="Inject through the search parameter and UNION-select the flag out of the secrets table." \
  remediation="Use parameterized queries / prepared statements; never concatenate user input into SQL." \
  hints="Break the query first: q=x' OR '1'='1  — do you get more rows than you should?
There is a table called 'secrets' with a column 'flag'.
q=x' UNION SELECT flag FROM secrets--   (mind the trailing space after --)." \
  provision="sqli_provision" toolkit="sqli_toolkit" handler="sqli_handle"
