#!/usr/bin/env bash
# =============================================================================
#  Easy — IDOR: Grade Record Access
#  Maps to report Check: fragile read-path authorization (per-object checks).
# =============================================================================

idor_provision() {
  local id="$1" d flag; d="$(pv_target_dir "$id")/grades"; mkdir -p "$d"
  flag="$(flags_plaintext "$id")"
  printf '{"student_id":1001,"name":"you","gpa":3.4,"instructor_note":"solid semester"}' > "$d/1001.json"
  printf '{"student_id":1002,"name":"sam carter","gpa":3.9,"instructor_note":"AP track"}'  > "$d/1002.json"
  printf '{"student_id":1337,"name":"j. okafor","gpa":4.0,"instructor_note":"CONFIDENTIAL — %s"}' "$flag" > "$d/1337.json"
}

# GET /api/grades/:id  — no ownership check (the bug).
idor_handle() {
  local rid f
  if [[ "$REQ_PATH" == /api/grades/* ]]; then
    rid="${REQ_PATH##*/}"
    f="$(pv_target_dir easy-idor)/grades/${rid}.json"
    if [[ -f "$f" ]]; then
      mw_resp "200 OK" "$(cat "$f")" "Content-Type: application/json"
    else
      mw_resp "404 Not Found" '{"error":"no such grade record"}'
    fi
  elif [[ "$REQ_PATH" == "/api/me" ]]; then
    mw_resp "200 OK" '{"student_id":1001,"name":"you"}'
  else
    mw_resp "404 Not Found" '{"error":"unknown route"}'
  fi
}

register_challenge \
  id="easy-idor" \
  title="IDOR: Grade Record Access - Easy" \
  diff="Easy" points="100" penalty="15" \
  owasp="A01:2021 Broken Access Control (IDOR)" \
  cvss="4.3 (AV:N/PR:L)" \
  slug="idor_grade_ledger" \
  finding="CoLab Pentest Report — fragile read-path checks (per-object authz)" \
  endpoint="GET /api/grades/:id" \
  tools="curl,httpie,jq" \
  scenario="You are signed in as student #1001 on the CoLab LMS. The grade API returns YOUR record at /api/grades/1001. But the controller looks records up by id alone and never checks that the record belongs to the caller. Other students' records sit at nearby ids." \
  objective="Enumerate the grade endpoint to read a record that isn't yours and recover the flag hidden in a confidential instructor note." \
  remediation="Enforce per-object ownership checks (scope queries to current_user); use non-sequential ids." \
  hints="Your own record is at /api/grades/1001 — what happens if you ask for a different id?
The interesting record is a 'confidential' one. Try ids around your own, and round numbers like 1337.
colab-http GET /api/grades/1337  — read the instructor_note field." \
  provision="idor_provision" handler="idor_handle"
