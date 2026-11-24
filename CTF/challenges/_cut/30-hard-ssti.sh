#!/usr/bin/env bash
# =============================================================================
#  Hard — Server-Side Template Injection: Report Generator
#  Teaching room (ERB SSTI). User-supplied template is rendered server-side;
#  escalate from expression evaluation to reading the flag file.
# =============================================================================

ssti_provision() {
  local id="$1"; printf '%s' "$(flags_plaintext "$id")" > "$(pv_target_dir "$id")/flag"
}

ssti_handle() {
  [[ "$REQ_PATH" == /api/report/generate ]] || { mw_resp "404 Not Found" '{"error":"unknown route"}'; return; }
  local tpl low; tpl="$(mw_field template)"; [[ -z "$tpl" ]] && tpl="$REQ_BODY"
  low="$(printf '%s' "$tpl" | tr '[:upper:]' '[:lower:]')"
  if [[ "$low" == *file.read*flag* || "$low" == *"cat /flag"* || "$low" == *"cat flag"* \
        || ( "$low" == *system* && "$low" == *flag* ) || ( "$low" == *read* && "$low" == *flag* ) \
        || ( "$low" == *'`'* && "$low" == *flag* ) ]]; then
    mw_resp "200 OK" "rendered => $(cat "$(pv_target_dir hard-ssti)/flag")"
  elif [[ "$tpl" == *'{{7*7}}'* || "$tpl" == *'7*7'* ]]; then
    mw_resp "200 OK" "rendered => 49    (the engine evaluated your expression — injection confirmed)"
  elif [[ "$tpl" == *'<%='* || "$tpl" == *'{{'* ]]; then
    mw_resp "200 OK" "rendered => (expression context reached — now do something with it)"
  else
    mw_resp "200 OK" "rendered => ${tpl:-<empty template>}"
  fi
}

register_challenge \
  id="hard-ssti" \
  title="Server-Side Template Injection: Report Generator - Hard" \
  diff="Hard" points="500" penalty="70" \
  owasp="A03:2021 Injection (SSTI)" \
  cvss="9.0 (AV:N/PR:L)" \
  slug="erb_template_rce_report" \
  finding="Teaching room — template injection was tested and hardened in the real engagement" \
  endpoint="POST /api/report/generate  (template=...)" \
  tools="curl,httpie" \
  scenario="The report generator lets staff pass a custom ERB template that is rendered server-side with the report data. Whatever you put in the template is evaluated by the server." \
  objective="Confirm the injection, then escalate to read the server's flag file via the template context." \
  remediation="Never render user-supplied templates; use a logic-less sandbox (e.g. Liquid) with a strict allow-list." \
  hints="Probe the injection point: template={{7*7}} (or <%= 7*7 %>). Does it echo 49?
You have expression evaluation — reach the filesystem. The flag lives at ./flag on the server.
template=<%= File.read('flag') %>   (or <%= \`cat flag\` %>)." \
  provision="ssti_provision" handler="ssti_handle"
