#!/usr/bin/env bash
# ============================================================================
# ctf_serv.sh — CoLab CTF launcher.
#
# COMPLETELY SEPARATE from the Sec engagement boot (sec_serv.sh / boot_mode.sh):
# it never selects a pentest mode, never writes containers/sec_env/.env, and
# never brings up the app/db/proxy target stack. It runs the self-contained
# CoLab CTF training range.
#
# It reuses the SEC TOOLKIT: by default the range runs INSIDE the same Kali
# toolbox image the engagement uses (colab_pentest), on its own isolated
# internal network, with this CTF/ folder bind-mounted writable at /opt/ctf.
# So you get curl, sqlmap, jwt_tool, ffuf, gitleaks, nuclei, python3, jq, etc.
# right alongside the challenges. A --host fallback runs it on the bare host.
#
# Usage:
#   ./ctf_serv.sh              launch the CTF inside the Kali toolbox (default)
#   ./ctf_serv.sh -p|--shell   drop into the Kali toolbox shell (CTF at /opt/ctf)
#   ./ctf_serv.sh -H|--host    run the CTF directly on the host (no container)
#   ./ctf_serv.sh -b|--build   build the toolbox image (reuses the Sec Dockerfile)
#   ./ctf_serv.sh -x|--down    remove the CTF container + internal network
#   ./ctf_serv.sh -h|--help    this help
# ============================================================================
set -uo pipefail

CTF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${CTF_DIR}/.." && pwd)"
IMAGE="colab_pentest:latest"
CONTAINER="colab_ctf_toolbox"
NET="colab_ctf_net"

if [ -t 1 ]; then
  C_RESET='\033[0m'; C_BOLD='\033[1m'; C_DIM='\033[2m'
  C_CYAN='\033[38;2;34;211;238m'; C_RED='\033[38;2;248;113;113m'
  C_GREEN='\033[32m'; C_YELLOW='\033[33m'
else
  C_RESET=''; C_BOLD=''; C_DIM=''; C_CYAN=''; C_RED=''; C_GREEN=''; C_YELLOW=''
fi
say()  { printf "%b\n" "$*"; }
err()  { printf "%b\n" "  ${C_RED}$*${C_RESET}" >&2; }

usage() { sed -n '2,23p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

# Host path in the form podman expects (native Windows path on Git Bash).
host_path() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi
}

have_podman() { command -v podman >/dev/null 2>&1; }

engine_ready() {
  have_podman || return 1
  podman info >/dev/null 2>&1
}

image_present() { podman image exists "$IMAGE" 2>/dev/null; }

ensure_net() {
  podman network exists "$NET" 2>/dev/null || \
    podman network create --internal "$NET" >/dev/null 2>&1 || true
}

# Interactive prefix: winpty gives a usable TTY for podman -it under Git Bash.
tty_prefix() {
  if command -v winpty >/dev/null 2>&1 && [ -t 0 ]; then printf 'winpty'; fi
}

# Common `podman run` args for an ephemeral CTF toolbox container.
run_toolbox() { # trailing args = command for /bin/bash
  ensure_net
  local mnt; mnt="$(host_path "$CTF_DIR")"
  # shellcheck disable=SC2046
  MSYS_NO_PATHCONV=1 $(tty_prefix) podman run --rm -it \
    --name "$CONTAINER" \
    --network "$NET" \
    --hostname colab-ctf \
    -e COLORTERM=truecolor -e TERM="${TERM:-xterm-256color}" \
    --entrypoint /bin/bash \
    -v "${mnt}:/opt/ctf" \
    -w /opt/ctf \
    "$IMAGE" "$@"
}

launch_ctf_toolbox() {
  say "  ${C_CYAN}${C_BOLD}CoLab CTF${C_RESET} — launching inside the Kali toolbox (${IMAGE})"
  say "  ${C_DIM}isolated internal net '${NET}' · CTF mounted at /opt/ctf · full Sec toolkit${C_RESET}\n"
  run_toolbox /opt/ctf/ctf.sh
}

launch_shell() {
  say "  ${C_CYAN}Kali toolbox shell${C_RESET} — CTF is at ${C_BOLD}/opt/ctf${C_RESET} (run ./ctf.sh)"
  say "  ${C_DIM}tools: curl sqlmap jwt_tool ffuf gitleaks nuclei nmap python3 jq …${C_RESET}\n"
  run_toolbox -l
}

launch_host() {
  say "  ${C_CYAN}${C_BOLD}CoLab CTF${C_RESET} — running on the host (no container)"
  say "  ${C_DIM}(uses whatever tools are on your host PATH)${C_RESET}\n"
  exec bash "${CTF_DIR}/ctf.sh"
}

teardown() {
  have_podman || { err "podman not found."; return 1; }
  podman rm -f "$CONTAINER" >/dev/null 2>&1 || true
  podman network rm "$NET"   >/dev/null 2>&1 || true
  say "  ${C_GREEN}✓ CTF container + network removed.${C_RESET}"
}

build_image() {
  have_podman || { err "podman not found."; return 1; }
  say "  building ${IMAGE} from the Sec pentest Dockerfile (large, one-time)…"
  ( cd "$REPO_ROOT" && podman build -t "$IMAGE" -f containers/agnostic/pentest/Dockerfile . )
}

MODE="up"
case "${1:-}" in
  ""|-u|--up)      MODE="up" ;;
  -p|--shell)      MODE="shell" ;;
  -H|--host)       MODE="host" ;;
  -b|--build)      MODE="build" ;;
  -x|--down|--teardown) MODE="down" ;;
  -h|--help)       usage; exit 0 ;;
  *) err "unknown option: $1"; usage; exit 2 ;;
esac

case "$MODE" in
  build) build_image; exit $? ;;
  down)  teardown;    exit $? ;;
  host)  launch_host ;;
  shell|up)
    if engine_ready && image_present; then
      [ "$MODE" = "shell" ] && launch_shell || launch_ctf_toolbox
    else
      if ! engine_ready; then
        err "podman engine not ready (is the podman machine started?  'podman machine start')."
      elif ! image_present; then
        err "toolbox image '${IMAGE}' not found — build it with:  ./ctf_serv.sh --build"
      fi
      say "  ${C_YELLOW}falling back to host mode…${C_RESET}\n"
      launch_host
    fi ;;
esac
