#!/usr/bin/env bash
# Smoke-test every CTF room: has a flag in the store, and boots (provision +
# toolkit stage) without error. Run in a toolbox with CTF at /opt/ctf.
set -uo pipefail
export CTF_HOME=/opt/ctf
cd /opt/ctf
source lib/ui.sh; source lib/mockweb.sh; source lib/flags.sh; source lib/state.sh
source lib/provision.sh; source lib/toolkit.sh; source lib/banner.sh; source lib/victory.sh
source lib/brief.sh; source lib/portal.sh
for f in challenges/*.sh; do source "$f"; done

printf '%-14s %-6s %-6s %s\n' "ROOM" "FLAG" "BOOT" "TITLE"
printf '%-14s %-6s %-6s %s\n' "----" "----" "----" "-----"
fail=0
for id in "${CHALLENGE_ORDER[@]}"; do
  if awk -F'\t' -v i="$id" '$1==i{found=1} END{exit found?0:1}' flags/flag-hashes.txt; then fl=ok; else fl=NO; fail=$((fail+1)); fi
  if provision_reset "$id" >/dev/null 2>&1 \
     && "${CH_PROVISION[$id]}" "$id" >/dev/null 2>&1 \
     && toolkit_prepare "$id" >/dev/null 2>&1; then boot=ok; else boot=FAIL; fail=$((fail+1)); fi
  printf '%-14s %-6s %-6s %s\n' "$id" "$fl" "$boot" "${CH_TITLE[$id]}"
done
echo
[ "$fail" -eq 0 ] && echo "ALL ROOMS: flag present + boot ok" || echo "ISSUES: $fail"
