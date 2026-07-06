#!/usr/bin/env bash
# =============================================================================
#  CRITICAL — SSRF: Internal Service Pivot
#  THE flagship finding from our engagement (CoLab Pentest Report Check 07):
#    Server-Side Request Forgery in LTI registration, endpoint /lti/tool_connect,
#    CVSS 9.3. An UNauthenticated outsider makes the server fetch arbitrary URLs,
#    pivoting into internal services + cloud credentials (Report Chain A).
#
#  The flag lives on an internal-only service that has NO route from the host /
#  outside world — reachable ONLY by pivoting the SSRF through the lab's
#  --internal network (169.254.169.254 metadata -> role creds).
# =============================================================================

ssrf_provision() {
  local id="$1"
  # In real (podman) mode this is a separate container on colab_ctf_net with no
  # host route; here it is an offline internal-service map. Either way the flag
  # is only obtainable by chaining the fetch through the vulnerable endpoint.
  case "$PV_ENGINE" in
    podman|docker)
      pv_note "$PV_ENGINE run -d --name colab_ctf_crit_ssrf --network $PV_NET \\"
      pv_note "    --network-alias 169.254.169.254 --network-alias metadata.internal \\"
      pv_note "    colab/ctf-imds:latest   # holds the role creds; NO -p host publish"
      pv_note "$PV_ENGINE run -d --name colab_ctf_${id//-/_} --network $PV_NET colab/ctf-lti:latest" ;;
  esac
  printf 'colab-app-role' > "$(pv_target_dir "$id")/role_name.txt"
}

# The vulnerable endpoint: POST /lti/tool_connect fetches a user-supplied URL
# server-side with no allow-list and no auth (the exact bug we reported).
ssrf_handle() {
  [[ "$REQ_PATH" == /lti/tool_connect ]] || { mw_resp "404 Not Found" '{"error":"unknown route"}'; return; }
  local url
  url="$(mw_field launch_url)"; [[ -z "$url" ]] && url="$(mw_field url)"
  [[ -z "$url" ]] && url="$(mw_field target_link_uri)"; [[ -z "$url" ]] && url="$(mw_query url)"
  if [[ -z "$url" ]]; then
    mw_resp "400 Bad Request" '{"error":"launch_url (LTI target_link_uri) required"}'; return
  fi
  local body; body="$(_ssrf_fetch "$url")"
  mw_resp "200 OK" "{\"tool\":\"registered\",\"server_fetched\":\"$url\",\"response\":$body}"
}

# Simulated server-side fetch across the INTERNAL network only.
_ssrf_fetch() {
  local u low; u="$1"; low="$(printf '%s' "$u" | tr '[:upper:]' '[:lower:]')"
  case "$low" in
    *169.254.169.254*security-credentials/colab-app-role*|*metadata*colab-app-role*)
      # pivot complete: internal-only creds document (contains the flag)
      printf '"IMDS role creds :: AccessKeyId=AKIACOLABLABONLY :: SecretAccessKey=%s"' "$(flags_plaintext crit-ssrf)" ;;
    *169.254.169.254*iam/security-credentials*|*/latest/meta-data/iam/*)
      printf '"%s"' "colab-app-role" ;;
    *169.254.169.254*|*metadata.internal*)
      printf '"%s"' "ami-id  hostname  iam/security-credentials/  (cloud metadata root)" ;;
    http://127.0.0.1*|http://localhost*|*colab-app*:*)
      printf '"%s"' "connection to loopback refused" ;;
    https://*|http://*)
      printf '"%s"' "fetched external URL (nothing internal here — pivot inward)" ;;
    *)
      printf '"%s"' "unsupported URL scheme" ;;
  esac
}

ssrf_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "ssrf-fetch.sh" \
"#!/usr/bin/env bash
# SSRF request harness for /lti/tool_connect.  usage: ./ssrf-fetch.sh <url>
exec ./colab-http POST /lti/tool_connect -d \"launch_url=\${1:?url required}\""
  toolkit_install_helper "$id" "TARGETS.txt" \
"# Internal-only hosts (no route from the host — reach them via the SSRF):
#   http://169.254.169.254/latest/meta-data/                      (cloud metadata root)
#   http://169.254.169.254/latest/meta-data/iam/security-credentials/
#   http://169.254.169.254/latest/meta-data/iam/security-credentials/<role>
# Pivot: list the role, then read that role's credentials document."
}

register_challenge \
  id="crit-ssrf" \
  title="SSRF: Internal Service Pivot - Critical" \
  diff="Critical" points="1000" penalty="140" \
  owasp="A10:2021 Server-Side Request Forgery" \
  cvss="9.3 (AV:N/PR:N/S:C)" \
  slug="lti_ssrf_metadata_pivot" \
  finding="CoLab Pentest Report Check 07 — SSRF in LTI registration (/lti/tool_connect), CVSS 9.3" \
  endpoint="POST /lti/tool_connect  (unauthenticated)" \
  tools="curl,httpie,jq" \
  scenario="This is the real critical from our engagement. The LTI tool-registration endpoint /lti/tool_connect takes a launch URL and the server fetches it — with no authentication and no allow-list. From outside, with no account, you can make CoLab's own server reach internal services that are otherwise unroutable." \
  objective="Abuse /lti/tool_connect to pivot into the internal cloud-metadata service and exfiltrate the role credentials. The flag is the internal role's secret — reachable ONLY through the SSRF." \
  remediation="Allow-list permitted hosts/schemes; require authentication; block link-local/metadata (169.254.169.254) & internal ranges; use IMDSv2." \
  hints="The endpoint fetches whatever launch_url you give it, server-side. Point it inward, not outward.
Cloud boxes expose credentials at 169.254.169.254 — start at /latest/meta-data/iam/security-credentials/ to learn the role name.
Two hops: (1) list the role, (2) read .../security-credentials/<role-name> for the secret. Use ./ssrf-fetch.sh <url>." \
  provision="ssrf_provision" toolkit="ssrf_toolkit" handler="ssrf_handle"
