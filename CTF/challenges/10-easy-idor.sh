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

# Which step is the student on? Reads what they've actually requested so the
# hint system reflects where they are, not a fixed sequence.
#   step 1 = hasn't tried an id other than their own
#   step 2 = enumerating other ids but hasn't hit the confidential 1337
#   step 3 = has read 1337; just needs to pull the flag out / submit
idor_hintstep() {
  local id="$1" prog; prog="$(pv_work_dir "$id")/.progress"
  [[ -f "$prog" ]] || { printf 1; return; }
  grep -q 'grades/1337' "$prog" && { printf 3; return; }
  if grep -oE 'grades/[0-9]+' "$prog" | grep -qvx 'grades/1001'; then printf 2; return; fi
  printf 1
}

# The CoLab "My Grades" page — the LMS the student attacks in the browser.
# Reads the student id from the URL (?id=, default 1001). No ownership check:
# changing the id in the address bar shows anyone's record → IDOR in the browser.
idor_portal() {
  local id="$1" sid="${CTF_PORTAL_ID:-1001}" f name gpa note
  sid="${sid//[^0-9]/}"; [[ -z "$sid" ]] && sid=1001
  f="$(pv_target_dir "$id")/grades/${sid}.json"
  printf '/api/grades/%s\n' "$sid" >> "$(pv_work_dir "$id")/.progress" 2>/dev/null || true
  colab_head "My Grades" grades
  if [[ -f "$f" ]]; then
    name="$(_portal_esc "$(grep -oE '"name":"[^"]*"' "$f" | head -1 | sed 's/.*:"//;s/"$//')")"
    gpa="$(grep -oE '"gpa":[0-9.]+' "$f" | head -1 | sed 's/.*://')"
    note="$(_portal_esc "$(grep -oE '"instructor_note":"[^"]*"' "$f" | head -1 | sed 's/.*:"//;s/"$//')")"
    [[ "$sid" != "1001" ]] && printf '<div class="warn">You are viewing <b>student #%s</b> — this record is not yours.</div>\n' "$sid"
    printf '<h1>My Grades</h1>\n'
    printf '<p class="sub">Record <span class="pill">student #%s</span> · term Fall 2026</p>\n' "$sid"
    printf '<div class="card">'
    printf '<div class="row"><span class="k">Student</span><span class="v">%s</span></div>' "$name"
    printf '<div class="row"><span class="k">Student ID</span><span class="v">#%s</span></div>' "$sid"
    printf '<div class="row"><span class="k">GPA</span><span class="v">%s</span></div>' "$gpa"
    printf '<div class="row"><span class="k">Instructor note</span><span class="v">%s</span></div>' "$note"
    printf '</div>\n'
  else
    printf '<h1>My Grades</h1>\n<div class="card"><div class="row"><span class="k">Student #%s</span><span class="v">no record found</span></div></div>\n' "$sid"
  fi
  colab_foot
}

# GET /api/grades/:id  — no ownership check (the bug).
idor_handle() {
  local rid f
  printf '%s\n' "$REQ_PATH" >> "$(pv_work_dir easy-idor)/.progress" 2>/dev/null || true
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
  browse="/" \
  portal="idor_portal" \
  hintstep="idor_hintstep" \
  hints="Your own record is at /api/grades/1001 — what happens if you ask for a different id?
The interesting record is a 'confidential' one. Try ids around your own, and round numbers like 1337.
colab-http GET /api/grades/1337  — read the instructor_note field." \
  provision="idor_provision" handler="idor_handle"
