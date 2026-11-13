#!/usr/bin/env bash
# =============================================================================
#  Easy - Sensitive Data Exposure: Verbose API Errors   (REAL CoLab, browser)
#  CoLab ships a diagnostics report endpoint whose debug error handler was left
#  enabled: GET /diagnostics/report?format_type=pdf works, but any other value
#  makes it rescue the exception and render the full backtrace + a config/ENV
#  dump - including REPORT_SIGNING_KEY - straight to the browser.
#
#  TRAINING PLATFORM: the verbose-error leak is embedded in a REAL CoLab
#  controller (DiagnosticsController, CTF/lab-setup/patch_verbose.rb) and renders
#  through the live app - no fake page. Simple -> done entirely in the browser by
#  changing one URL value, like the IDOR room.
# =============================================================================

verbose_provision() { return 0; }   # endpoint embedded out-of-band (apply-embeds.ps1)

verbose_handle() {
  mw_resp "200 OK" '{"note":"Box targets the REAL CoLab app in the browser. Type !hint for the steps."}' \
    "Content-Type: application/json"
}

register_challenge \
  id="easy-verbose" \
  title="Sensitive Data Exposure: Verbose API Errors - Easy" \
  diff="Easy" points="100" penalty="15" \
  owasp="A05:2021 Security Misconfiguration (verbose errors)" \
  cvss="5.3 (AV:N/PR:N/C:L)" \
  slug="verbose_error_signing_key" \
  finding="CoLab Pentest Report - debug error pages left enabled in production (secrets in backtrace)" \
  endpoint="GET /diagnostics/report?format_type=..." \
  tools="browser" \
  scenario="CoLab has a report diagnostics endpoint that works for one format and was shipped with debug error output still enabled. When it hits input it does not expect, instead of a clean error it renders a full Ruby backtrace and a dump of environment/config - secrets included - right in your browser." \
  objective="Open the report endpoint in the browser, feed it a format it does not handle, and read the leaked REPORT_SIGNING_KEY out of the error page." \
  remediation="Disable verbose/debug error pages in production (render generic 500s); never print ENV/secrets in error output; keep signing keys out of the environment dump surface." \
  browse="https://localhost:13443/diagnostics/report?format_type=pdf" \
  live="https://localhost:13443/diagnostics/report?format_type=pdf" \
  hints="Open the working endpoint first:  https://localhost:13443/diagnostics/report?format_type=pdf  - it returns a normal JSON report.
Now change the format to something the server doesn't support, e.g. change format_type=pdf to format_type=xml in the address bar and press Enter.
The server is in debug mode, so it dumps the exception + a config block to the page. Read REPORT_SIGNING_KEY - that's the flag." \
  provision="verbose_provision" handler="verbose_handle"
