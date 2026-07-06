#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — standalone launcher  (the "/CTF" entry point)
#  Reached from the base lab launcher via menu [4], or run directly:
#     ./CTF/ctf.sh
#  This module is fully self-contained and shares nothing with the Black/White/
#  Gray box ("Sec") boot modes.
#
#  Hidden subcommand:
#     ctf.sh __serve <challenge_id> METHOD PATH ...   (used by colab-http)
# =============================================================================
set -uo pipefail   # deliberately NOT -e: this is an interactive TUI

CTF_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CTF_HOME

# ---- load libraries (order matters) -----------------------------------------
source "$CTF_HOME/lib/ui.sh"
source "$CTF_HOME/lib/mockweb.sh"
source "$CTF_HOME/lib/flags.sh"
source "$CTF_HOME/lib/state.sh"
source "$CTF_HOME/lib/provision.sh"
source "$CTF_HOME/lib/toolkit.sh"
source "$CTF_HOME/lib/banner.sh"

# ---- auto-discover challenges (00-common.sh sorts first) --------------------
for _cf in "$CTF_HOME"/challenges/*.sh; do
  [[ -e "$_cf" ]] && source "$_cf"
done
unset _cf

# ---- hidden request dispatcher for colab-http -------------------------------
ctf_serve() {
  shift                     # drop "__serve"
  local id="${1:-}"; shift || true
  mw_parse "$@"
  local fn="${CH_HANDLER[$id]:-}"
  if [[ -z "$fn" ]] || ! declare -F "$fn" >/dev/null 2>&1; then
    printf 'colab-http: no handler registered for challenge "%s"\n' "$id" >&2
    return 1
  fi
  "$fn"
}

if [[ "${1:-}" == "__serve" ]]; then
  ctf_serve "$@"
  exit $?
fi

# ---- scope / isolation banner -----------------------------------------------
ctf_scope_banner() {
  printf '  %s┌────────────────────────── SCOPE & ISOLATION ──────────────────────┐%s\n' "$T_RED" "$T_RESET"
  printf '  %s│%s authorized SURE training only · faculty-supervised · FERPA-scoped  %s│%s\n' "$T_RED" "$T_RESET" "$T_RED" "$T_RESET"
  printf '  %s│%s targets live ONLY on the internal Podman net — no host/outside route %s│%s\n' "$T_RED" "$T_RESET" "$T_RED" "$T_RESET"
  printf '  %s│%s deliberately vulnerable · never touches real CoLab infrastructure  %s│%s\n' "$T_RED" "$T_RESET" "$T_RED" "$T_RESET"
  printf '  %s└───────────────────────────────────────────────────────────────────┘%s\n' "$T_RED" "$T_RESET"
}

ctf_header() {
  local total avail cap n
  total="$(state_total_points)"; avail="$(state_total_available)"
  cap="$(state_captured_count)"; n="${#CHALLENGE_ORDER[@]}"
  printf '  %sSCORE%s %s%s%s / %s     %sROOMS%s %s%s/%s%s cleared     %sflag:%s CoLab{...}\n' \
    "$T_BOLD$T_CYAN" "$T_RESET" "$T_BOLD$T_YELLOW" "$total" "$T_RESET" "$avail" \
    "$T_BOLD$T_CYAN" "$T_RESET" "$T_GREEN" "$cap" "$n" "$T_RESET" "$T_DIM" "$T_RESET"
  provision_engine_line
}

ctf_list() {
  local i=0 id prevdiff="" diff mark
  for id in "${CHALLENGE_ORDER[@]}"; do
    i=$(( i + 1 ))
    diff="${CH_DIFF[$id]}"
    if [[ "$diff" != "$prevdiff" ]]; then
      printf '\n  %s%s%s\n' "$(ui_difficulty_color "$diff")$T_BOLD" "${diff^^}" "$T_RESET"
      prevdiff="$diff"
    fi
    if state_is_captured "$id"; then mark="${T_GREEN}[✓]${T_RESET}"; else mark="${T_SLATE}[ ]${T_RESET}"; fi
    printf '   %s %s[%2d]%s %-52s %s%4s%s\n' \
      "$mark" "$T_CYAN" "$i" "$T_RESET" "${CH_TITLE[$id]}" \
      "$(ui_difficulty_color "$diff")" "${CH_POINTS[$id]}p" "$T_RESET"
  done
}

ctf_reset_all() {
  local ans
  printf '\n  reset ALL progress and re-provision every room? [y/N] ❯ '
  read -r ans || return 0
  case "$ans" in
    y|Y|yes)
      local id
      for id in "${CHALLENGE_ORDER[@]}"; do
        provision_reset "$id"; "${CH_PROVISION[$id]}" "$id"; toolkit_prepare "$id"
      done
      state_reset_all
      printf '  %s✓ all rooms reset.%s\n' "$T_GREEN" "$T_RESET"; sleep 1 ;;
    *) printf '  %scancelled.%s\n' "$T_SLATE" "$T_RESET"; sleep 1 ;;
  esac
}

ctf_teardown() {
  local ans
  printf '\n  tear down all targets + internal network? (progress kept) [y/N] ❯ '
  read -r ans || return 0
  case "$ans" in
    y|Y|yes) provision_teardown_all; printf '  %s✓ torn down.%s\n' "$T_GREEN" "$T_RESET"; sleep 1 ;;
    *) printf '  %scancelled.%s\n' "$T_SLATE" "$T_RESET"; sleep 1 ;;
  esac
}

ctf_main() {
  flags_seed          # generate plaintext (gitignored) + hash store if needed
  state_init
  local sel n="${#CHALLENGE_ORDER[@]}"
  while true; do
    ui_clear
    banner_wordmark
    ctf_scope_banner
    echo
    ctf_header
    ctf_list
    printf '\n  %s[1-%s]%s open a room    %s[a]%s reset all    %s[t]%s teardown    %s[q]%s quit\n' \
      "$T_CYAN" "$n" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_SLATE" "$T_RESET"
    printf '  %scolab-ctf%s %s❯%s ' "$T_DIM" "$T_RESET" "$T_CYAN" "$T_RESET"
    read -r sel || break
    sel="$(printf '%s' "$sel" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
    case "$sel" in
      q|quit|exit) break ;;
      a|reset)     ctf_reset_all ;;
      t|teardown)  ctf_teardown ;;
      "")          : ;;
      *[!0-9]*)    printf '  %sinvalid selection.%s\n' "$T_RED" "$T_RESET"; sleep 1 ;;
      *)
        if (( sel >= 1 && sel <= n )); then
          challenge_open "${CHALLENGE_ORDER[$(( sel - 1 ))]}"
        else
          printf '  %sno room #%s.%s\n' "$T_RED" "$sel" "$T_RESET"; sleep 1
        fi ;;
    esac
  done
  printf '\n  %sLeaving CoLab CTF. Score kept: %s/%s across %s/%s rooms.%s\n\n' \
    "$T_SLATE" "$(state_total_points)" "$(state_total_available)" \
    "$(state_captured_count)" "$n" "$T_RESET"
}

ctf_main "$@"
