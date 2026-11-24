#!/usr/bin/env bash
# =============================================================================
#  Hard - Insecure Deserialization: Unsigned Marshal RCE   (REAL CoLab app)
#  CoLab's "restore saved view" feature base64-decodes a `state` parameter and
#  Marshal.loads it with NO signature/verification. Ruby runs Class._load during
#  Marshal.load, so a crafted serialized object is remote code execution. NOTHING
#  is handed to the player: no signing key, no staged exploit - they build the
#  gadget themselves with the ruby in the toolkit, send it, and exfiltrate a
#  server-only secret via CoLab's public dir. Embedded by patch_deser_unsigned.rb.
#
#  Solve path (hints walk it, penalised): notice the endpoint Marshal-loads your
#  base64 blob -> build a gadget object whose deserialization shells out -> have
#  it copy /app/tmp/colab_secret_flag into public/ and fetch it.
# =============================================================================

deser_provision() { return 0; }   # sink + gadget + secret baked into the app image

deser_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "NOTES.txt" \
"# Recon notes - CoLab 'restore saved view':
#     GET /api/prefs/restore?state=<base64>
#         -> Base64-decodes 'state' and Marshal.load()s it (no signature check)
# Marshalling untrusted data is RCE. There is a server-only secret at
# /app/tmp/colab_secret_flag that only code execution on the server can read;
# CoLab serves anything dropped into /app/public/ at the web root.
# Tools for this room: ruby, curl."
}

register_challenge \
  id="hard-deser" \
  title="Insecure Deserialization: Unsigned Marshal RCE - Hard" \
  diff="Hard" points="500" \
  owasp="A08:2021 Software & Data Integrity Failures" \
  cvss="9.0 (AV:N/PR:N/C:H/I:H/A:H)" \
  slug="unsigned_marshal_rce" \
  finding="CoLab Pentest Report - user-supplied state blob Marshal.load-ed without verification (deserialization RCE)" \
  endpoint="GET /api/prefs/restore?state=<base64 Marshal blob>" \
  tools="curl,ruby" \
  scenario="CoLab's 'restore saved view' feature takes a base64 'state' blob and Marshal-deserializes it to rebuild your saved preferences - with no signature or verification. Marshalling untrusted data is remote code execution. There is a secret the server can read that you cannot reach any other way." \
  objective="Craft a serialized object that runs a command on the CoLab server, read the server-only secret file, and exfiltrate the flag (drop it into a web-reachable path and fetch it)." \
  remediation="Never Marshal.load attacker-influenced data - use a safe format (JSON) for client state; if you must deserialize, verify an HMAC first and allow-list classes; treat all client input as hostile." \
  hints="Look at /api/prefs/restore - it base64-decodes your 'state' and Marshal.load()s it. Marshal.load of attacker data is dangerous: Ruby runs a class's _load method as it deserializes.
Build a gadget: a Ruby class whose _dump carries a shell command and whose deserialization runs it. Marshal.dump an instance, base64url it (strip '='), and pass it as state. Example skeleton:  class CtfDeserGadget; def initialize(c);@c=c;end; def _dump(_);@c.to_s;end; end
You can't see command output in the response, so make the command copy the secret into CoLab's public dir and fetch it:  cmd = 'cat /app/tmp/colab_secret_flag > /app/public/loot.txt'  then  curl 'http://app:3000/api/prefs/restore?state=<blob>'  and  curl http://app:3000/loot.txt" \
  provision="deser_provision" toolkit="deser_toolkit" handler=""
