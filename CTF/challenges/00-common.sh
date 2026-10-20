#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — challenge framework (registry + per-challenge flow)
#
#  Adding a challenge later = drop a new file in challenges/ that:
#    1. defines its provision / toolkit / handler functions, and
#    2. calls register_challenge with key=value metadata.
#  ctf.sh auto-discovers challenges/*.sh; the menu, flag seed, scoring and
#  progress all key off the registry below. No other file needs editing.
# =============================================================================

declare -A CH_TITLE CH_DIFF CH_POINTS CH_HINT_PENALTY CH_OWASP CH_CVSS CH_SLUG \
           CH_TOOLS CH_OBJECTIVE CH_SCENARIO CH_ENDPOINT CH_REMEDIATION \
           CH_FINDING CH_HINTS CH_PROVISION CH_TOOLKIT CH_HANDLER CH_BROWSE CH_HINTSTEP CH_PORTAL
CHALLENGE_ORDER=()

register_challenge() {
  local id="" title="" diff="" points="" penalty="" owasp="" cvss="" slug="" \
        tools="" objective="" scenario="" endpoint="" remediation="" finding="" \
        hints="" provision="" toolkit="" handler="" browse="" hintstep="" portal=""
  local kv key val
  for kv in "$@"; do
    key="${kv%%=*}"; val="${kv#*=}"
    case "$key" in
      id) id="$val";; title) title="$val";; diff) diff="$val";; points) points="$val";;
      penalty) penalty="$val";; owasp) owasp="$val";; cvss) cvss="$val";; slug) slug="$val";;
      tools) tools="$val";; objective) objective="$val";; scenario) scenario="$val";;
      endpoint) endpoint="$val";; remediation) remediation="$val";; finding) finding="$val";;
      hints) hints="$val";; provision) provision="$val";; toolkit) toolkit="$val";; handler) handler="$val";;
      browse) browse="$val";; hintstep) hintstep="$val";; portal) portal="$val";;
    esac
  done
  [[ -z "$id" ]] && { echo "register_challenge: missing id" >&2; return 1; }
  CHALLENGE_ORDER+=("$id")
  CH_TITLE[$id]="$title";        CH_DIFF[$id]="$diff";       CH_POINTS[$id]="$points"
  CH_HINT_PENALTY[$id]="$penalty"; CH_OWASP[$id]="$owasp";   CH_CVSS[$id]="$cvss"
  CH_SLUG[$id]="$slug";          CH_TOOLS[$id]="$tools";     CH_OBJECTIVE[$id]="$objective"
  CH_SCENARIO[$id]="$scenario";  CH_ENDPOINT[$id]="$endpoint"; CH_REMEDIATION[$id]="$remediation"
  CH_FINDING[$id]="$finding";    CH_HINTS[$id]="$hints";     CH_PROVISION[$id]="$provision"
  CH_TOOLKIT[$id]="$toolkit";    CH_HANDLER[$id]="$handler"
  CH_BROWSE[$id]="$browse";      CH_HINTSTEP[$id]="$hintstep";   CH_PORTAL[$id]="$portal"
}

# ---- helpers ----------------------------------------------------------------
_wrap() { # text [width] [indent]
  local text="$1" width="${2:-62}" indent="${3:-  }"
  printf '%s\n' "$text" | fold -s -w "$width" | sed "s/^/$indent/"
}

challenge_badge() {
  local id="$1" col; col="$(ui_difficulty_color "${CH_DIFF[$id]}")"
  printf '%s[ %s · %s pts ]%s' "$col" "${CH_DIFF[$id]}" "${CH_POINTS[$id]}" "$T_RESET"
}

_challenge_status_line() {
  local id="$1" mark
  if state_is_captured "$id"; then
    mark="${T_GREEN}✓ captured (${T_RESET}$(state_field "$id" 3)${T_GREEN} pts)${T_RESET}"
  else
    mark="${T_SLATE}○ not captured${T_RESET}"
  fi
  printf '  %s   hints used: %s/%s\n' "$mark" "$(state_hints_used "$id")" "$(toolkit_hint_count "$id")"
}

# ---- TryHackMe-style briefing card ------------------------------------------
challenge_briefing() {
  local id="$1"
  ui_clear
  ui_box_top; ui_box_title "${CH_TITLE[$id]}"; ui_box_bottom
  printf '\n  %s   %s%s%s\n\n' "$(challenge_badge "$id")" "$T_DIM" "report ref: ${CH_FINDING[$id]}" "$T_RESET"
  printf '  %sScenario%s\n' "$T_BOLD$T_SKY" "$T_RESET"
  _wrap "${CH_SCENARIO[$id]}"
  printf '\n  %sYour objective%s\n' "$T_BOLD$T_SKY" "$T_RESET"
  _wrap "${CH_OBJECTIVE[$id]}"
  echo
  ui_kv "Vulnerability" "${CH_OWASP[$id]}"
  ui_kv "Endpoint"      "${CH_ENDPOINT[$id]:-—}" "$T_CYAN"
  ui_kv "CVSS"          "${CH_CVSS[$id]:-—}"
  ui_kv "Reward"        "${CH_POINTS[$id]} pts" "$(ui_difficulty_color "${CH_DIFF[$id]}")"
  if [[ -n "${CTF_TARGET_PID:-}" ]]; then
    ui_kv "Attack target" "${TARGET_URL:-http://127.0.0.1:8000}  (curl · sqlmap · ffuf …)" "$T_RED"
  else
    ui_kv "Attack target" "./colab-http  (offline mock in the room work dir)" "$T_RED"
  fi
  echo
}

# ---- "READY TO START" go-screen ---------------------------------------------
# Shown AFTER the lab is fully booted (challenge_boot). ASCII banner + status;
# Enter engages, [b] drops back to the main menu (target stays armed).
challenge_ready_gate() { # id
  local id="$1" ans
  ui_clear
  banner_ready
  ui_box_top; ui_box_title "READY TO START — ${CH_TITLE[$id]}"; ui_box_bottom
  printf '\n  %s●%s lab fully booted — target armed · flag planted · toolkit staged\n' \
    "$T_GREEN" "$T_RESET"
  printf '  %starget%s  %s%s%s    %sendpoint%s  %s%s%s\n' \
    "$T_SLATE" "$T_RESET" "$T_BOLD$T_RED" "${TARGET_URL:-./colab-http}" "$T_RESET" \
    "$T_SLATE" "$T_RESET" "$T_CYAN" "${CH_ENDPOINT[$id]:-—}" "$T_RESET"
  printf '\n  %sReady to start?%s   %s[Enter]%s engage    %s[b]%s back to menu\n' \
    "$T_BOLD$T_SKY" "$T_RESET" "$T_GREEN" "$T_RESET" "$T_SLATE" "$T_RESET"
  printf '  %s%s ❯%s ' "$T_DIM" "$id" "$T_RESET"
  if [[ ! -t 0 ]]; then printf '\n'; sleep 2; return 0; fi   # non-interactive → show, then engage
  read -r ans || return 1
  case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]' | tr -d ' \r')" in
    b|back|q) return 1 ;;
    *) return 0 ;;
  esac
}

_boot_step() { # pct label  — redraw one loading-bar line in place
  printf '\r  %s%3d%%%s %s  %s%-40s%s' \
    "$T_BOLD$T_YELLOW" "$1" "$T_RESET" "$(ui_bar "$1" 28)" "$T_SKY" "$2" "$T_RESET"
}

# Provision the room behind a loading bar tracking the REAL boot steps. The
# steps' own output (sim-mode podman recipes, etc.) goes to state/boot.log so
# the single-line bar stays intact.
challenge_boot() { # id
  local id="$1" log="$CTF_HOME/state/boot.log"
  : > "$log" 2>/dev/null || true
  echo
  printf '  %sdeploying %s…%s\n\n' "$T_DIM" "${CH_TITLE[$id]}" "$T_RESET"
  _boot_step 10 "establishing isolated network"
  provision_net                 >>"$log" 2>&1; sleep 0.25
  _boot_step 35 "provisioning target + planting flag"
  provision_reset "$id"         >>"$log" 2>&1
  "${CH_PROVISION[$id]}" "$id"  >>"$log" 2>&1; sleep 0.25
  _boot_step 65 "arming live HTTP target"
  ctf_target_active "$id"       >>"$log" 2>&1; sleep 0.25
  _boot_step 90 "staging toolkit, objective + hints"
  toolkit_prepare "$id"         >>"$log" 2>&1; sleep 0.25
  _boot_step 100 "ready"; sleep 0.25
  printf '\n\n  %s✓%s target up · flag planted · toolkit staged  %s(boot log: state/boot.log)%s\n' \
    "$T_GREEN" "$T_RESET" "$T_DIM" "$T_RESET"
}

# ---- open / play a challenge ------------------------------------------------
challenge_open() {
  local id="$1"
  ui_clear
  challenge_boot "$id"                       # loading bar — boot the lab FIRST
  challenge_ready_gate "$id" || return 0    # ASCII "READY" go-screen, shown once booted
  challenge_briefing "$id"                   # working view: scenario + target card
  provision_engine_line
  echo
  toolkit_summary "$id"
  if [[ -n "${CTF_TARGET_PID:-}" ]]; then
    printf '\n  %sHit it:%s %scurl %s%s%s  ·  or ./colab-http in the work dir  ·  point sqlmap/ffuf here too\n' \
      "$T_DIM" "$T_RESET" "$T_CYAN" "${TARGET_URL:-}" "$T_RESET" "$T_DIM"
  else
    printf '\n  %sTip:%s cd into the working dir and use %s./colab-http%s to hit the target.\n' \
      "$T_DIM" "$T_RESET" "$T_CYAN" "$T_RESET"
  fi
  challenge_menu "$id"
}

challenge_menu() {
  local id="$1" choice
  while true; do
    echo
    _challenge_status_line "$id"
    printf '  %s[s]%s submit  %s[h]%s hint  %s[t]%s toolkit  %s[r]%s reset  %s[w]%s writeup  %s[i]%s briefing  %s[b]%s back\n' \
      "$T_CYAN" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_CYAN" "$T_RESET" \
      "$T_CYAN" "$T_RESET" "$T_CYAN" "$T_RESET" "$T_SLATE" "$T_RESET"
    printf '  %stype %s!hint%s anytime for a hint%s\n' "$T_DIM" "$T_YELLOW" "$T_RESET$T_DIM" "$T_RESET"
    printf '  %s%s ❯%s ' "$T_DIM" "${id}" "$T_RESET"
    read -r choice || return 0
    case "$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]' | tr -d ' \r')" in
      s|submit)         challenge_submit "$id" ;;
      h|hint|'!hint'|'!hints') challenge_hint "$id" ;;
      t|toolkit|kit)    ctf_toolkit_menu "$id" ;;
      r|reset)    challenge_reset "$id" ;;
      w|writeup)  challenge_writeup "$id" ;;
      i|brief|briefing) challenge_briefing "$id"; toolkit_summary "$id" ;;
      b|back|q)   return 0 ;;
      *)          printf '  %sunknown option%s\n' "$T_RED" "$T_RESET" ;;
    esac
  done
}

challenge_submit() {
  local id="$1" input award
  printf '  %spaste captured flag ❯%s ' "$T_CYAN" "$T_RESET"
  read -r input || return 0
  input="${input%$'\r'}"; input="${input#"${input%%[![:space:]]*}"}"; input="${input%"${input##*[![:space:]]}"}"
  if flags_verify "$id" "$input"; then
    if state_is_captured "$id"; then
      printf '  %s✓ correct — this room is already on your board.%s\n' "$T_GREEN" "$T_RESET"
    else
      award="$(state_capture "$id")"
      challenge_celebrate "$id" "$award"
      challenge_offer_writeup "$id"
      # Easter egg: all rooms captured → show the completion trophy.
      if declare -F ctf_victory >/dev/null 2>&1 && \
         (( $(state_captured_count) == ${#CHALLENGE_ORDER[@]} )); then
        ctf_victory
      fi
    fi
  else
    printf '  %s✗ incorrect flag.%s keep going — attempts are unlimited.\n' "$T_RED" "$T_RESET"
  fi
}

challenge_celebrate() {
  local id="$1" award="$2"
  echo
  printf '  %s╔══════════════════════════════════════════╗%s\n' "$T_GREEN" "$T_RESET"
  printf '  %s║%s   %s✦ FLAG CAPTURED ✦%s   %s+%-5s pts%s          %s║%s\n' \
    "$T_GREEN" "$T_RESET" "$T_BOLD$T_GREEN" "$T_RESET" "$T_YELLOW" "$award" "$T_RESET" "$T_GREEN" "$T_RESET"
  printf '  %s╚══════════════════════════════════════════╝%s\n' "$T_GREEN" "$T_RESET"
  printf '  %s%s%s captured.\n' "$T_WHITE" "${CH_TITLE[$id]}" "$T_RESET"
  printf '  running score: %s%s%s / %s   ·   %s%s/%s%s rooms cleared\n' \
    "$T_BOLD$T_YELLOW" "$(state_total_points)" "$T_RESET" "$(state_total_available)" \
    "$T_GREEN" "$(state_captured_count)" "${#CHALLENGE_ORDER[@]}" "$T_RESET"
}

challenge_hint() {
  local id="$1" total used ans idx
  total="$(toolkit_hint_count "$id")"
  used="$(state_hints_used "$id")"
  if (( total == 0 )); then printf '  %sno hints for this room.%s\n' "$T_SLATE" "$T_RESET"; return; fi
  if state_is_captured "$id"; then
    printf '  %sall hints (already captured — no penalty):%s\n' "$T_SLATE" "$T_RESET"
    local i; for (( i=1; i<=total; i++ )); do printf '   %d. %s\n' "$i" "$(toolkit_get_hint "$id" "$i")"; done
    return
  fi
  if (( used >= total )); then
    printf '  %sall %s hints already revealed:%s\n' "$T_SLATE" "$total" "$T_RESET"
    local i; for (( i=1; i<=total; i++ )); do printf '   %d. %s\n' "$i" "$(toolkit_get_hint "$id" "$i")"; done
    return
  fi
  # Step-reflective: if the room defines a hintstep hook, show the hint for the
  # step the student is actually on (based on their logged progress); else the
  # next sequential hint.
  idx=""
  if [[ -n "${CH_HINTSTEP[$id]:-}" ]] && declare -F "${CH_HINTSTEP[$id]}" >/dev/null 2>&1; then
    idx="$("${CH_HINTSTEP[$id]}" "$id" 2>/dev/null)"
  fi
  [[ "$idx" =~ ^[0-9]+$ ]] || idx=$(( used + 1 ))
  (( idx < 1 )) && idx=1; (( idx > total )) && idx=total
  printf '  reveal the hint for your current step (%s/%s)? costs %s%s pts%s [y/N] ❯ ' \
    "$idx" "$total" "$T_YELLOW" "${CH_HINT_PENALTY[$id]}" "$T_RESET"
  read -r ans || return 0
  case "$ans" in
    y|Y|yes)
      state_use_hint "$id" >/dev/null
      toolkit_write_hints "$id"
      printf '  %sStep %s:%s %s\n' "$T_YELLOW" "$idx" "$T_RESET" "$(toolkit_get_hint "$id" "$idx")"
      printf '  %s(award if solved now: %s pts)%s\n' "$T_DIM" "$(state_award_value "$id")" "$T_RESET" ;;
    *) printf '  %scancelled.%s\n' "$T_SLATE" "$T_RESET" ;;
  esac
}

challenge_reset() {
  local id="$1" ans
  printf '  reset & re-provision this room (clears its capture/progress)? [y/N] ❯ '
  read -r ans || return 0
  case "$ans" in
    y|Y|yes)
      provision_reset "$id"
      "${CH_PROVISION[$id]}" "$id"
      state_reset "$id"
      toolkit_prepare "$id"
      printf '  %s✓ room reset — fresh target, progress cleared.%s\n' "$T_GREEN" "$T_RESET" ;;
    *) printf '  %scancelled.%s\n' "$T_SLATE" "$T_RESET" ;;
  esac
}

challenge_writeup() {
  local id="$1" f; f="$(pv_work_dir "$id")/WRITEUP.md"
  toolkit_writeup_template "$id"
  printf '  %swriteup template:%s %s\n' "$T_SLATE" "$T_RESET" "$f"
  if [[ -n "${EDITOR:-}" ]] && command -v "${EDITOR%% *}" >/dev/null 2>&1; then
    "$EDITOR" "$f"
  else
    printf '  %s(set $EDITOR to open it automatically; showing it below)%s\n\n' "$T_DIM" "$T_RESET"
    sed 's/^/    /' "$f"
  fi
}

challenge_offer_writeup() {
  local id="$1" ans
  printf '\n  journal this solve in a scratch writeup? [y/N] ❯ '
  read -r ans || return 0
  case "$ans" in y|Y|yes) challenge_writeup "$id" ;; esac
}
