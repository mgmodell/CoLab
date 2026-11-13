#!/usr/bin/env bash
# =============================================================================
#  CRITICAL - SSRF: Internal Service Pivot   (REAL CoLab app, toolkit/terminal)
#  CoLab's LTI tool-registration endpoint, GET|POST /lti/tool_connect, takes an
#  openid_configuration URL and the server FETCHES it - unauthenticated, no
#  allow-list (LtiController#register: Net::HTTP.get_response(URI(params[...]))).
#  An outsider makes CoLab's own server reach internal-only services.
#
#  TRAINING PLATFORM: the SSRF is REAL and already in CoLab. We embed the juicy
#  target it pivots into - a loopback-only "cloud metadata" service
#  (InternalController#metadata, CTF/lab-setup/patch_ssrf.rb) that is 403 to the
#  outside world but answers CoLab's own loopback fetch. The flag is its secret,
#  reachable ONLY by chaining the fetch through /lti/tool_connect.
#
#  More complex than the easy rooms -> solved from the CTF toolkit terminal
#  with curl (per the lab's "give them the tools in the terminal" rule).
# =============================================================================

ssrf_provision() { return 0; }   # embedded + started out-of-band (lab-setup/apply-embeds.ps1)

ssrf_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "TARGETS.txt" \
"# Internal-only host - NO route from the toolbox; reach it via the SSRF:
#   http://127.0.0.1:3000/internal/metadata   (server loopback 'cloud metadata')
# Vulnerable endpoint (unauthenticated):
#   GET http://app:3000/lti/tool_connect?openid_configuration=<URL CoLab will fetch>
# CoLab GETs your URL, then POSTs to the registration_endpoint it returns, and
# reflects that response body back to you - that reflection is your exfil channel."
}

register_challenge \
  id="crit-ssrf" \
  title="SSRF: Internal Service Pivot - Hard" \
  diff="Hard" points="500" \
  owasp="A10:2021 Server-Side Request Forgery" \
  cvss="9.3 (AV:N/PR:N/S:C)" \
  slug="lti_ssrf_metadata_pivot" \
  finding="CoLab Pentest Report Check 07 - SSRF in LTI registration (/lti/tool_connect), CVSS 9.3" \
  endpoint="GET /lti/tool_connect?openid_configuration=<url>  (unauthenticated)" \
  tools="curl,jq" \
  scenario="CoLab's LTI tool-registration endpoint takes an openid_configuration URL and the server fetches it - with no authentication and no allow-list. From outside, with no account, you can make CoLab's own server reach internal services that are otherwise unroutable. There is a 'cloud metadata' service bound to the server's loopback that holds a secret; it answers 403 to everyone but the server itself." \
  objective="Pivot /lti/tool_connect into the loopback-only internal metadata service and exfiltrate its secret. The flag is reachable ONLY through the SSRF - a direct request to the metadata service is refused." \
  remediation="Allow-list permitted hosts/schemes; block loopback/link-local/internal ranges (127.0.0.0/8, 169.254.0.0/16, RFC1918); require authentication; resolve-and-pin the host to defeat DNS rebinding." \
  hints="Try to reach the internal service directly first: curl http://app:3000/internal/metadata - it answers 403 (loopback only). You need the SERVER to fetch it for you.
The vulnerable endpoint fetches whatever you pass in openid_configuration, server-side: curl 'http://app:3000/lti/tool_connect?openid_configuration=http://127.0.0.1:3000/internal/metadata'
CoLab fetches that loopback URL and reflects the internal response back in the page. Grep the output for CoLab{...}." \
  provision="ssrf_provision" toolkit="ssrf_toolkit" handler=""
