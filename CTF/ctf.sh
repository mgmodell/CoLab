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
source "$CTF_HOME/lib/victory.sh"
source "$CTF_HOME/lib/brief.sh"
source "$CTF_HOME/lib/portal.sh"

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

# ---- hidden briefing renderer for the target server (Chrome boot-up page) ----
if [[ "${1:-}" == "__brief" ]]; then
  ctf_brief_html "${2:-}"
  exit $?
fi

# ---- hidden CoLab-site renderer for the target server (the vulnerable page) --
if [[ "${1:-}" == "__portal" ]]; then
  ctf_portal_html "${2:-}"
  exit $?
fi

# ---- real HTTP target (gives rooms a genuine attack IP:port) -----------------
TARGET_PORT="${CTF_TARGET_PORT:-8000}"
TARGET_IP="$( { hostname -I 2>/dev/null || hostname -i 2>/dev/null; } | awk '{print $1}' )"
[[ -z "$TARGET_IP" ]] && TARGET_IP="127.0.0.1"
if [[ -n "${CTF_TARGET_REAL:-}" ]]; then
  TARGET_URL="$CTF_TARGET_REAL"; CTF_TARGET_PID="live"   # rooms attack the live CoLab app (Podman)
else
  TARGET_URL="http://${TARGET_IP}:${TARGET_PORT}"; CTF_TARGET_PID=""
fi

# Point the target server at the room the operator is currently in.
ctf_target_active() { printf '%s' "${1:-}" > "$CTF_HOME/state/active_challenge" 2>/dev/null || true; }

ctf_target_start() {
  [[ -n "${CTF_TARGET_REAL:-}" ]] && return 0          # live app is the target; no local mock needed
  command -v python3 >/dev/null 2>&1 || return 0     # optional; ./colab-http still works
  mkdir -p "$CTF_HOME/state"; ctf_target_active ""
  CTF_TARGET_PORT="$TARGET_PORT" python3 "$CTF_HOME/lib/target_server.py" \
      >"$CTF_HOME/state/target_server.log" 2>&1 &
  CTF_TARGET_PID=$!
  sleep 0.4
  kill -0 "$CTF_TARGET_PID" 2>/dev/null || CTF_TARGET_PID=""
}
ctf_target_stop() { [[ "$CTF_TARGET_PID" =~ ^[0-9]+$ ]] && kill "$CTF_TARGET_PID" 2>/dev/null; CTF_TARGET_PID=""; }
trap ctf_target_stop EXIT

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
  printf '  %sSCORE%s %s%s%s / %s     %sROOMS%s %s%s/%s%s cleared     %sPLAYER%s %s%s%s\n' \
    "$T_BOLD$T_CYAN" "$T_RESET" "$T_BOLD$T_YELLOW" "$total" "$T_RESET" "$avail" \
    "$T_BOLD$T_CYAN" "$T_RESET" "$T_GREEN" "$cap" "$n" "$T_RESET" \
    "$T_BOLD$T_CYAN" "$T_RESET" "$T_BOLD$T_WHITE" "${CTF_PROFILE:-player}" "$T_RESET"
  provision_engine_line
  if [[ -n "${CTF_TARGET_REAL:-}" ]]; then
    printf '  %sTARGET%s %s%s%s  %s(the live CoLab app · Podman --internal net)%s\n' \
      "$T_BOLD$T_RED" "$T_RESET" "$T_BOLD$T_WHITE" "$TARGET_URL" "$T_RESET" "$T_DIM" "$T_RESET"
  elif [[ -n "$CTF_TARGET_PID" ]]; then
    printf '  %sTARGET%s %s%s%s  %s(serves the room you open · also http://127.0.0.1:%s)%s\n' \
      "$T_BOLD$T_RED" "$T_RESET" "$T_BOLD$T_WHITE" "$TARGET_URL" "$T_RESET" "$T_DIM" "$TARGET_PORT" "$T_RESET"
  else
    printf '  %sTARGET%s %soffline mock — attack via ./colab-http (install python3 for a live HTTP target)%s\n' \
      "$T_BOLD$T_RED" "$T_RESET" "$T_DIM" "$T_RESET"
  fi
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

# Tool catalog — one "cmd|description|example" line each. The example's live
# target URL/port/IP are expanded at render time. Consumed by both the full
# toolkit view and the per-room view, so new tools are added in ONE place.
# Fundamentals-first kit: the tools a student needs to PERFORM each technique by
# hand. No one-button auto-exploiters (sqlmap/hydra/metasploit) - this is a
# learn-the-attack range, not a press-and-win one. The per-room view filters this
# to the tools that room declares (CH_TOOLS).
_tk_catalog() { # target_url
  local u="$1"
  cat <<CAT
curl|raw HTTP requests - the workhorse|curl $u/api/reports/admin
jq|parse JSON responses|curl -s $u/api/portal/login | jq .
jwt_tool|crack & forge JSON Web Tokens|jwt_tool <token> -C -d /usr/share/wordlists/rockyou.txt
ruby|craft payloads / serialize objects|ruby -rbase64 -e 'print Base64.urlsafe_encode64(Marshal.dump(obj))'
python3|quick scripting / encoders|python3 -c 'import base64,sys; ...'
base64|encode / decode blobs|echo <data> | base64 -d
openssl|hashing / HMAC / TLS|openssl dgst -sha256 -hmac <key>
nmap|port / service scan|nmap -sV $TARGET_HOST
ffuf|content / endpoint discovery|ffuf -u $u/FUZZ -w /usr/share/wordlists/dirb/common.txt
gobuster|directory brute force|gobuster dir -u $u -w /usr/share/wordlists/dirb/common.txt
nc|raw TCP / banner grab|nc $TARGET_HOST 80
CAT
}

_tk_row() { # cmd  desc  example  [name_color]
  local cmd="$1" desc="$2" ex="$3" col="${4:-$T_WHITE}" mark
  if command -v "$cmd" >/dev/null 2>&1; then mark="${T_GREEN}✓${T_RESET}"; else mark="${T_SLATE}○${T_RESET}"; fi
  printf '   %s %s%-12s%s %s%-30s%s %s%s%s\n' \
    "$mark" "$col" "$cmd" "$T_RESET" "$T_SLATE" "$desc" "$T_RESET" "$T_DIM" "$ex" "$T_RESET"
}

# Does room $1 declare tool $2 in its CH_TOOLS?
_tk_wanted() { local csv=",${CH_TOOLS[$1]//[[:space:]]/},"; [[ "$csv" == *",$2,"* ]]; }

# Optional arg: a room id → show a focused "for this room" kit; else the full set.
ctf_toolkit_menu() {
  local room="${1:-}" choice u="$TARGET_URL" cmd desc ex
  while true; do
    ui_clear
    printf '\n  %s❯ TOOLKIT%s  %s(Kali toolbox — same tools as the Sec engagement)%s\n' \
      "$T_BOLD$T_CYAN" "$T_RESET" "$T_DIM" "$T_RESET"
    if [[ -n "$CTF_TARGET_PID" ]]; then
      printf '  %sattack target%s  %s%s%s  %s(serves whichever room you open)%s\n' \
        "$T_SLATE" "$T_RESET" "$T_BOLD$T_RED" "$u" "$T_RESET" "$T_DIM" "$T_RESET"
    else
      printf '  %sattack target%s  %soffline mock — use ./colab-http (install python3 for a live target)%s\n' \
        "$T_SLATE" "$T_RESET" "$T_DIM" "$T_RESET"
    fi

    if [[ -n "$room" ]]; then
      printf '\n  %sfor this room%s  %s%s%s\n' "$T_BOLD$T_SKY" "$T_RESET" "$T_WHITE" "${CH_TITLE[$room]}" "$T_RESET"
      printf '  %sendpoint%s  %s%s%s\n\n' "$T_SLATE" "$T_RESET" "$T_CYAN" "${CH_ENDPOINT[$room]:-—}" "$T_RESET"
      while IFS='|' read -r cmd desc ex; do
        [[ -z "$cmd" ]] && continue
        _tk_wanted "$room" "$cmd" && _tk_row "$cmd" "$desc" "$ex" "$T_BOLD$T_WHITE"
      done < <(_tk_catalog "$u")
      printf '\n  %sthese are the tools this room calls for · the full kit is on the main menu [t].%s\n' "$T_DIM" "$T_RESET"
    else
      printf '\n'
      while IFS='|' read -r cmd desc ex; do
        [[ -z "$cmd" ]] && continue
        _tk_row "$cmd" "$desc" "$ex"
      done < <(_tk_catalog "$u")
      printf '\n  %sEach room also stages ./colab-http + room-specific helpers in its working dir.%s\n' "$T_DIM" "$T_RESET"
    fi

    [[ -n "$room" ]] && printf '  %stype %s!hint%s anytime for a hint toward the solution%s\n' "$T_DIM" "$T_YELLOW" "$T_RESET$T_DIM" "$T_RESET"
    printf '\n  %s[s]%s drop to a Kali shell    %s[b]%s back\n' "$T_CYAN" "$T_RESET" "$T_CYAN" "$T_RESET"
    printf '  %stoolkit%s %s❯%s ' "$T_DIM" "$T_RESET" "$T_CYAN" "$T_RESET"
    read -r choice || return 0
    case "$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]' | tr -d ' \r')" in
      s|shell)
        local _wd="$CTF_HOME"
        [[ -n "$room" ]] && _wd="$(pv_work_dir "$room")"
        printf '\n  %sKali shell in %s%s%s — the exploit helper %s./attack%s is here. type %sexit%s to return.%s\n\n' \
          "$T_DIM" "$T_WHITE" "$_wd" "$T_DIM" "$T_CYAN" "$T_DIM" "$T_BOLD" "$T_RESET$T_DIM" "$T_RESET"
        ( cd "$_wd" && "${SHELL:-bash}" -i ) ;;
      '!hint'|'!hints'|hint)
        if [[ -n "$room" ]]; then challenge_hint "$room"
          printf '  %s(enter to continue)%s ' "$T_DIM" "$T_RESET"; read -r _ || true
        fi ;;
      b|back|q) return 0 ;;
    esac
  done
}

# (completion trophy easter egg lives in lib/victory.sh → ctf_victory)

# Ask who's playing so progress is saved to (and resumed from) their own profile.
ctf_select_user() {
  local name last="" def
  [[ -f "$CTF_HOME/state/.last_user" ]] && last="$(cat "$CTF_HOME/state/.last_user" 2>/dev/null)"
  if [[ -n "${CTF_USER:-}" ]]; then
    name="$CTF_USER"                       # non-interactive (env / launcher)
  else
    def="${last:-player}"
    printf '\n  %sWho'\''s playing?%s  a name saves your progress across sessions  %s[%s]%s\n' \
      "$T_BOLD$T_SKY" "$T_RESET" "$T_DIM" "$def" "$T_RESET"
    printf '  %sname%s %s❯%s ' "$T_DIM" "$T_RESET" "$T_CYAN" "$T_RESET"
    read -r name || name=""
    [[ -z "$name" ]] && name="$def"
  fi
  state_set_profile "$name"
  printf '%s' "$CTF_PROFILE" > "$CTF_HOME/state/.last_user" 2>/dev/null || true
}

ctf_main() {
  flags_seed          # generate plaintext (gitignored) + hash store if needed
  ui_clear
  banner_wordmark
  ctf_select_user     # pick/create the player profile
  state_init          # load (or create) that profile's progress
  ctf_target_start    # bring up the live HTTP target (optional; needs python3)
  local cap; cap="$(state_captured_count)"
  if (( cap > 0 )); then
    printf '\n  %s✓ welcome back, %s — resuming %s pts across %s/%s rooms.%s\n' \
      "$T_GREEN" "$CTF_PROFILE" "$(state_total_points)" "$cap" "${#CHALLENGE_ORDER[@]}" "$T_RESET"
    sleep 1.3
  else
    printf '\n  %snew profile "%s" — good luck!%s\n' "$T_SLATE" "$CTF_PROFILE" "$T_RESET"
    sleep 0.8
  fi
  local sel n="${#CHALLENGE_ORDER[@]}"
  while true; do
    ui_clear
    ctf_target_active ""      # main menu → target shows the landing page
    banner_wordmark
    ctf_scope_banner
    echo
    ctf_header
    ctf_list
    printf '\n  %s[1-%s]%s open room   %s[t]%s toolkit   %s[f]%s complete CTF   %s[a]%s reset all   %s[x]%s teardown   %s[q]%s quit\n' \
      "$T_CYAN" "$n" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_SLATE" "$T_RESET"
    printf '  %scolab-ctf%s %s❯%s ' "$T_DIM" "$T_RESET" "$T_CYAN" "$T_RESET"
    read -r sel || break
    sel="$(printf '%s' "$sel" | tr '[:upper:]' '[:lower:]' | tr -d ' \r')"
    case "$sel" in
      q|quit|exit) break ;;
      t|toolkit)   ctf_toolkit_menu ;;
      f|finish|complete|score|done) ctf_final_score ;;
      a|reset)     ctf_reset_all ;;
      x|teardown|down) ctf_teardown ;;
      v|victory|trophy)   # hidden: re-view the completion screen once unlocked
        if (( $(state_captured_count) == n )); then ctf_victory
        else printf '  %s%s/%s rooms cleared — finish them all to unlock it.%s\n' \
               "$T_SLATE" "$(state_captured_count)" "$n" "$T_RESET"; sleep 1.2; fi ;;
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

# --- Host-orchestrated split (no background job) ------------------------------
# ctf_serv.ps1 runs the menu as two phases via `podman exec -it`:
#   __pick : show the menu, pick + confirm a room, run the loading bar, then EXIT
#            (writing state/selected_room + state/selected_url). The host then
#            opens Chrome itself and calls __room.
#   __room : briefing + the room's toolkit/hint/submit menu, until [b] back.
# This lets the host open Chrome synchronously between the two, with no watcher.

ctf_pick() {
  flags_seed
  ui_clear; banner_wordmark
  ctf_select_user
  state_init
  rm -f "$CTF_HOME/state/selected_room" "$CTF_HOME/state/selected_url" "$CTF_HOME/state/ctl" 2>/dev/null || true
  local sel n="${#CHALLENGE_ORDER[@]}" id ans
  while true; do
    ui_clear; banner_wordmark; ctf_scope_banner; echo; ctf_header; ctf_list
    printf '\n  %s[1-%s]%s pick a vulnerability   %s[f]%s complete CTF (final score)   %s[q]%s quit\n' \
      "$T_CYAN" "$n" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_SLATE" "$T_RESET"
    printf '  %scolab-ctf%s %s❯%s ' "$T_DIM" "$T_RESET" "$T_CYAN" "$T_RESET"
    read -r sel || { printf 'quit' > "$CTF_HOME/state/ctl"; return 0; }
    sel="$(printf '%s' "$sel" | tr '[:upper:]' '[:lower:]' | tr -d ' \r')"
    case "$sel" in
      q|quit|exit) printf 'quit' > "$CTF_HOME/state/ctl"; return 0 ;;
      f|finish|complete|score|done) ctf_final_score ;;
      ''|*[!0-9]*) printf '  %sinvalid selection.%s\n' "$T_RED" "$T_RESET"; sleep 1 ;;
      *)
        if (( sel >= 1 && sel <= n )); then
          id="${CHALLENGE_ORDER[$(( sel - 1 ))]}"
          # confirm this is the vulnerability they want
          ui_clear; ui_box_top; ui_box_title "${CH_TITLE[$id]}"; ui_box_bottom
          printf '\n  %s   %s%s%s\n\n' "$(challenge_badge "$id")" "$T_DIM" "${CH_OWASP[$id]}" "$T_RESET"
          _wrap "${CH_SCENARIO[$id]}"; echo
          printf '\n  %sStart this room?%s  %s[Enter]%s yes   %s[b]%s pick another\n' \
            "$T_BOLD$T_SKY" "$T_RESET" "$T_GREEN" "$T_RESET" "$T_SLATE" "$T_RESET"
          printf '  %s%s ❯%s ' "$T_DIM" "$id" "$T_RESET"
          read -r ans || ans=""
          case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]' | tr -d ' \r')" in
            b|back|n|no) : ;;                       # loop back to the picker
            *) challenge_boot "$id"                 # loading bar (provision + stage + selected_url)
               printf '%s' "$id" > "$CTF_HOME/state/selected_room"
               return 0 ;;
          esac
        else
          printf '  %sno room #%s.%s\n' "$T_RED" "$sel" "$T_RESET"; sleep 1
        fi ;;
    esac
  done
}

ctf_room() {
  local id="${1:-}"
  [[ -z "$id" ]] && return 0
  state_init
  challenge_briefing "$id"   # clears the screen and draws the room header itself
  provision_engine_line; echo
  toolkit_summary "$id"
  printf '\n  %sAttack from the toolkit: %s[t]%s toolkit then %s[s]%s for a Kali shell. Type %s!hint%s for help.%s\n' \
    "$T_DIM" "$T_CYAN" "$T_RESET$T_DIM" "$T_CYAN" "$T_RESET$T_DIM" "$T_YELLOW" "$T_RESET$T_DIM" "$T_RESET"
  challenge_menu "$id"
}

case "${1:-}" in
  __pick) ctf_pick ;;
  __room) ctf_room "${2:-}" ;;
  *)      ctf_main "$@" ;;
esac
