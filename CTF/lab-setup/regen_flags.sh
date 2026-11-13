#!/usr/bin/env bash
# Force-regenerate the CTF flag store (flags/flag-hashes.txt + state/flags.plain)
# after adding/renaming a room or changing fixed flags. Run inside a toolbox with
# CTF bind-mounted at /opt/ctf:   bash /opt/ctf/lab-setup/regen_flags.sh
set -uo pipefail
export CTF_HOME=/opt/ctf
cd /opt/ctf
source lib/ui.sh; source lib/mockweb.sh; source lib/flags.sh; source lib/state.sh
source lib/provision.sh; source lib/toolkit.sh; source lib/banner.sh; source lib/victory.sh
source lib/brief.sh; source lib/portal.sh
for f in challenges/*.sh; do source "$f"; done

flags_seed --force

echo "=== rooms (menu order) ==="
i=0; for id in "${CHALLENGE_ORDER[@]}"; do i=$((i+1)); printf '  %2d. %s\n' "$i" "$id"; done
echo "=== real-app flags in the store ==="
grep -E 'easy-sqli|easy-idor' flags/flag-hashes.txt state/flags.plain
