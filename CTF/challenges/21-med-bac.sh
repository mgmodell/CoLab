#!/usr/bin/env bash
# =============================================================================
#  Medium — Broken Access Control: Instructor Panel
#  Maps to report Check 08/10: mass-assignment self-promotion to "researcher"
#  (CVSS 7.1). A student flips their own role via the account-update endpoint,
#  then reaches the staff-only instructor panel.
# =============================================================================

bac_provision() {
  local id="$1"; printf 'student' > "$(pv_target_dir "$id")/role.txt"
}

bac_handle() {
  local rf; rf="$(pv_target_dir med-bac)/role.txt"
  [[ -f "$rf" ]] || printf 'student' > "$rf"
  case "$REQ_METHOD $REQ_PATH" in
    "PATCH /api/account"|"PUT /api/account"|"POST /api/account")
      # Mass assignment: `role` should never be settable by the user (the bug).
      local role; role="$(mw_field role)"
      [[ -n "$role" ]] && printf '%s' "$role" > "$rf"
      mw_resp "200 OK" "{\"id\":1001,\"name\":\"you\",\"role\":\"$(cat "$rf")\"}" ;;
    "GET /api/account")
      mw_resp "200 OK" "{\"id\":1001,\"role\":\"$(cat "$rf")\"}" ;;
    "GET /instructor/panel")
      case "$(cat "$rf")" in
        instructor|researcher|admin)
          mw_resp "200 OK" "{\"panel\":\"instructor\",\"cross_course_rosters\":true,\"flag\":\"$(flags_plaintext med-bac)\"}" ;;
        *)
          mw_resp "403 Forbidden" '{"error":"students may not view the instructor panel"}' ;;
      esac ;;
    *) mw_resp "404 Not Found" '{"error":"unknown route"}' ;;
  esac
}

register_challenge \
  id="med-bac" \
  title="Broken Access Control: Instructor Panel - Medium" \
  diff="Medium" points="250" penalty="35" \
  owasp="A01:2021 Broken Access Control (mass assignment)" \
  cvss="7.1 (AV:N/PR:L)" \
  slug="researcher_role_selfgrant" \
  finding="CoLab Pentest Report Check 08/10 — mass-assignment 'researcher' (CVSS 7.1)" \
  endpoint="PATCH /api/account  →  GET /instructor/panel" \
  tools="curl,httpie,jq" \
  scenario="As a student you are blocked from /instructor/panel (403). But the account-update endpoint binds attributes straight from the request body — including a 'role' field the app never meant to expose. This is exactly the privilege-escalation we flagged as High." \
  objective="Promote your own account to a privileged role via mass assignment, then open the instructor panel and grab the flag." \
  remediation="Strong-params: remove 'role' from permitted attributes; authorize role changes server-side only." \
  hints="Check your current role: colab-http GET /api/account.
The update endpoint (PATCH /api/account) trusts whatever fields you send. What field controls access?
colab-http PATCH /api/account -d 'role=researcher'  then  colab-http GET /instructor/panel." \
  provision="bac_provision" handler="bac_handle"
