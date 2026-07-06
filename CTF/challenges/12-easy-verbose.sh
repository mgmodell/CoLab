#!/usr/bin/env bash
# =============================================================================
#  Easy — Sensitive Data Exposure: Verbose API Errors
#  Maps to report Check: secrets exposure + verbose error handling. An
#  unhandled code path returns a full stack trace that leaks a signing key.
# =============================================================================

verbose_provision() { :; }   # stateless target

# GET /api/report?format=pdf  → ok
# GET /api/report?format=<anything else / missing> → verbose 500 leaking config
verbose_handle() {
  [[ "$REQ_PATH" == /api/report ]] || { mw_resp "404 Not Found" '{"error":"unknown route"}'; return; }
  local fmt; fmt="$(mw_query format)"
  if [[ "$fmt" == "pdf" ]]; then
    mw_resp "200 OK" '{"report":"generated","format":"pdf","rows":12}'
  else
    mw_resp "500 Internal Server Error" "RuntimeError: unsupported report format: '${fmt:-<nil>}'
  app/services/report_generator.rb:44:in \`render'
  config/initializers/secrets.rb:7  (ENV fallback dumped)
      RAILS_ENV=production   DB_HOST=db.internal
      REPORT_SIGNING_KEY=$(flags_plaintext easy-verbose)
  app/controllers/reports_controller.rb:19:in \`show'
  ...  (full backtrace rendered to client — debug mode left on)"
  fi
}

register_challenge \
  id="easy-verbose" \
  title="Sensitive Data Exposure: Verbose API Errors - Easy" \
  diff="Easy" points="100" penalty="15" \
  owasp="A05:2021 Security Misconfiguration / A04 (verbose errors)" \
  cvss="5.3 (AV:N/PR:N)" \
  slug="verbose_error_signing_key" \
  finding="CoLab Pentest Report — secrets exposure + debug error handling" \
  endpoint="GET /api/report?format=..." \
  tools="curl,httpie" \
  scenario="The report endpoint works for format=pdf. In production the app was shipped with debug error pages on, so any unhandled code path renders a full Ruby backtrace — including a dump of environment config — straight to the client." \
  objective="Trigger an unhandled error on the report endpoint and read the leaked REPORT_SIGNING_KEY from the stack trace." \
  remediation="Disable verbose/debug errors in production; return generic 500s; keep secrets out of code and logs." \
  hints="The happy path is GET /api/report?format=pdf. What if the format is something the server doesn't handle?
An unexpected or missing format value throws — and the server is in debug mode.
colab-http GET '/api/report?format=xml'  and read REPORT_SIGNING_KEY in the trace." \
  provision="verbose_provision" handler="verbose_handle"
