#!/usr/bin/env bash
# =============================================================================
#  Medium - CSRF: Account Recovery Email   (REAL CoLab app, browser + PoC page)
#  CoLab's account-security page changes the recovery email through a
#  cookie-authenticated, state-changing GET with NO anti-CSRF token
#  (AccountSecurityController#change; CoLab globally skips
#  verify_authenticity_token). The session cookie is SameSite=Lax, so it rides
#  along on a top-level navigation - which means an attacker page can make a
#  logged-in victim's browser silently flip their recovery email.
#
#  TRAINING PLATFORM: the vulnerable endpoints are REAL CoLab controllers
#  (CTF/lab-setup/patch_csrf.rb). The attacker's PoC page is - by definition -
#  attacker-hosted; it lives in your kit (csrf-poc.html). More complex ->
#  terminal-staged PoC + browser.
# =============================================================================

csrf_provision() { return 0; }   # endpoints embedded out-of-band (apply-embeds.ps1)

csrf_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "NOTES.txt" \
"# Recon notes - CSRF on the account recovery email:
#   Victim account page:  https://localhost:13443/account/security
#       (shows the current recovery email; sets a SameSite=Lax session cookie)
#   Change endpoint:  GET /account/security/change?recovery=<new>
#       cookie-authenticated, state-changing GET, with NO anti-CSRF token.
#   Reset the room:   https://localhost:13443/account/security/reset
# An attacker PAGE you build (a .html file you open in the browser) can make the
# logged-in victim's browser issue that GET - the Lax cookie rides a top-level
# navigation. Tools: browser, a text editor."
}

register_challenge \
  id="med-csrf" \
  title="CSRF: Account Recovery Email - Medium" \
  diff="Medium" points="250" penalty="35" \
  owasp="A01:2021 Broken Access Control (CSRF / CWE-352)" \
  cvss="6.5 (AV:N/UI:R/I:H)" \
  slug="csrf_recovery_email" \
  finding="CoLab Pentest Report - state-changing GET with no anti-CSRF token on account recovery email" \
  endpoint="GET /account/security/change?recovery=...  (cookie-auth, no CSRF token)" \
  tools="browser" \
  scenario="CoLab lets a signed-in user change their account recovery email. The change is an ordinary GET request, authenticated only by the session cookie, with no anti-CSRF token - and CoLab disables Rails' CSRF checks globally. The session cookie is SameSite=Lax, so it is still sent when the browser follows a top-level link. That means a page you control can make a logged-in victim's browser change their recovery email without them realizing - the first step of an account takeover." \
  objective="Using an attacker-controlled page (csrf-poc.html in your kit), forge a cross-site request that changes the logged-in victim's recovery email to the attacker's address. CoLab reveals the flag once the recovery email has been flipped." \
  remediation="Require a per-request anti-CSRF token (re-enable verify_authenticity_token); never perform state changes on GET; set session cookies SameSite=Strict for sensitive actions and re-authenticate before changing recovery contacts." \
  browse="https://localhost:13443/account/security" \
  live="https://localhost:13443/account/security" \
  hints="Open the victim's account page so you're 'signed in': https://localhost:13443/account/security - note the recovery email, and that changing it is just a GET (no hidden CSRF token). Visiting this page also sets the SameSite=Lax session cookie.
You need a page YOU control (a different origin) that makes the victim's browser issue that GET. Make a local .html file whose form auto-submits to the change endpoint, then open it in the same browser while 'logged in'.
Save this as poc.html and open it:  <form id=f action='https://localhost:13443/account/security/change' method=GET><input type=hidden name=recovery value='attacker@evil.example'></form><script>f.submit()</script>  - the Lax cookie rides the navigation, CoLab flips the recovery email and shows the flag. (Reset: https://localhost:13443/account/security/reset)" \
  provision="csrf_provision" toolkit="csrf_toolkit" handler=""
