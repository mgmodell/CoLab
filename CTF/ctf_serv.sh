#!/usr/bin/env bash
# ============================================================================
# ctf_serv.sh — CoLab CTF launcher (Git Bash / Linux).
#
# Boots the CoLab CTF training range IN PODMAN — inside the same Kali toolbox
# image the engagement uses (colab_pentest), so students get the full toolkit
# (curl, sqlmap, jwt_tool, ffuf, gitleaks, nuclei, python3, jq …) right next to
# the challenges. Runs on its own isolated internal network with this CTF/
# folder bind-mounted writable at /opt/ctf. Progress is saved on the host.
#
# COMPLETELY SEPARATE from the Sec engagement boot: it never runs boot_mode.sh,
# never writes containers/sec_env/.env, and never starts the app/db/proxy stack.
#
# Usage (run from a HOST shell — Git Bash):
#   ./ctf_serv.sh              Boot the CTF in podman and play  (default)
#   ./ctf_serv.sh -p|--shell   Open the Kali toolbox shell (CTF at /opt/ctf)
#   ./ctf_serv.sh -s|--status  Show engine/image status
#   ./ctf_serv.sh -b|--build   Build the toolbox image (one-time, reuses Sec Dockerfile)
#   ./ctf_serv.sh -x|--down     Remove the CTF container + internal network
#   ./ctf_serv.sh -H|--host     Run on the bare host instead of podman (fallback)
#   ./ctf_serv.sh -h|--help     This help
#
# PowerShell users: run  .\ctf_serv.ps1  instead (same behaviour, native TTY).
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
say() { printf "%b\n" "$*"; }
err() { printf "%b\n" "  ${C_RED}$*${C_RESET}" >&2; }
usage() { sed -n '2,24p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

have_podman() { command -v podman >/dev/null 2>&1; }
image_present() { podman image exists "$IMAGE" 2>/dev/null; }

host_path() { # podman wants a native Windows path under Git Bash
  if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi
}
tty_prefix() { # winpty gives podman -it a usable TTY under Git Bash
  if command -v winpty >/dev/null 2>&1 && [ -t 0 ]; then printf 'winpty'; fi
}

# Make sure the Podman engine is reachable. On Windows/macOS the machine is
# usually just stopped after a reboot — try to start it, then bail clearly.
ensure_engine() {
  have_podman || { err "'podman' was not found on PATH. Install Podman Desktop, then retry."; return 1; }
  podman info >/dev/null 2>&1 && return 0
  if podman machine list --format '{{.Name}}' 2>/dev/null | grep -q .; then
    say "  ${C_DIM}Podman engine not ready — starting the podman machine (one moment)…${C_RESET}"
    podman machine start >/dev/null 2>&1 || true
  fi
  podman info >/dev/null 2>&1 && return 0
  err "cannot reach the Podman engine."
  say "  Start it and re-run:   ${C_BOLD}podman machine start${C_RESET}"
  return 1
}

ensure_image() {
  image_present && return 0
  err "toolbox image '${IMAGE}' isn't built yet (one-time build, ~8 GB)."
  say "  Build it:   ${C_BOLD}./ctf_serv.sh -b${C_RESET}   (or reuse the Sec lab:  ./sec_serv.sh -b )"
  return 1
}

ensure_net() {
  podman network exists "$NET" 2>/dev/null || \
    podman network create --internal "$NET" >/dev/null 2>&1 || true
}

# podman run for an ephemeral CTF toolbox container. Args = command for bash.
run_toolbox() {
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

boot_ctf() {
  ensure_engine || exit 1
  ensure_image  || exit 1
  say "  ${C_CYAN}${C_BOLD}CoLab CTF${C_RESET} — booting in Podman (${IMAGE})"
  say "  ${C_DIM}isolated internal net '${NET}' · CTF at /opt/ctf · full Sec toolkit · progress saved on host${C_RESET}\n"
  run_toolbox /opt/ctf/ctf.sh
  say "\n  ${C_DIM}CTF container stopped — your progress is saved.${C_RESET}"
}

open_shell() {
  ensure_engine || exit 1
  ensure_image  || exit 1
  say "  ${C_CYAN}Kali toolbox shell${C_RESET} — CTF is at ${C_BOLD}/opt/ctf${C_RESET}  (run ./ctf.sh)"
  say "  ${C_DIM}tools: curl sqlmap jwt_tool ffuf gitleaks nuclei nmap python3 jq …${C_RESET}\n"
  run_toolbox -l
}

run_host() {
  say "  ${C_YELLOW}Running the CTF on the bare host (not podman).${C_RESET}"
  say "  ${C_DIM}(uses whatever tools are on your host PATH)${C_RESET}\n"
  exec bash "${CTF_DIR}/ctf.sh"
}

status() {
  say "  ${C_BOLD}CoLab CTF — status${C_RESET}"
  if have_podman && podman info >/dev/null 2>&1; then
    say "    engine : ${C_GREEN}podman ready${C_RESET}"
  else
    say "    engine : ${C_RED}not ready${C_RESET}  (run: podman machine start)"
  fi
  if image_present; then say "    image  : ${C_GREEN}${IMAGE} present${C_RESET}"
  else say "    image  : ${C_RED}${IMAGE} missing${C_RESET}  (run: ./ctf_serv.sh -b)"; fi
  if podman ps --format '{{.Names}}' 2>/dev/null | grep -qx "$CONTAINER"; then
    say "    running: ${C_GREEN}${CONTAINER}${C_RESET}"
  else
    say "    running: ${C_DIM}(no CTF container up)${C_RESET}"
  fi
}

teardown() {
  have_podman || { err "podman not found."; return 1; }
  podman rm -f "$CONTAINER" >/dev/null 2>&1 || true
  podman network rm "$NET"   >/dev/null 2>&1 || true
  say "  ${C_GREEN}✓ CTF container + network removed.${C_RESET}"
}

build_image() {
  ensure_engine || return 1
  say "  building ${IMAGE} from the Sec pentest Dockerfile (large, one-time)…"
  ( cd "$REPO_ROOT" && podman build -t "$IMAGE" -f containers/agnostic/pentest/Dockerfile . )
}

case "${1:-}" in
  ""|-u|--up)            boot_ctf ;;
  -p|--shell)           open_shell ;;
  -s|--status)          status ;;
  -b|--build)           build_image ;;
  -x|--down|--teardown) teardown ;;
  -H|--host)            run_host ;;
  -h|--help)            usage ;;
  *) err "unknown option: $1"; usage; exit 2 ;;
esac
