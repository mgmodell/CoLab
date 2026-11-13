#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — completion easter egg (the victory trophy)
#  Shown when a player captures all rooms. Kept in its own module so it can be
#  rendered standalone (demos/tests) as well as from ctf.sh.
#  Needs: ui.sh (ui_fg/ui_reset/T_*), state.sh (score), and CHALLENGE_ORDER.
# =============================================================================

_ctf_rstrip() { local s="$1"; printf '%s' "${s%"${s##*[![:space:]]}"}"; }

_ctf_center() { # width colorvar text
  local w="$1" col="$2" text="$3" pad; pad=$(( (w - ${#text}) / 2 )); (( pad < 0 )) && pad=0
  printf '%*s%s%s%s\n' "$pad" "" "$col" "$text" "$T_RESET"
}

# Centered typewriter reveal (falls back to instant when not a TTY).
_ctf_type() { # width colorvar text
  local w="$1" col="$2" text="$3" pad i; pad=$(( (w - ${#text}) / 2 )); (( pad < 0 )) && pad=0
  printf '%*s%s' "$pad" "" "$col"
  if [ -t 1 ]; then
    for ((i=0; i<${#text}; i++)); do printf '%s' "${text:i:1}"; sleep 0.012; done
  else
    printf '%s' "$text"
  fi
  printf '%s\n' "$T_RESET"
}

# Skull art. Top cap (line 1) is nudged right so the crown centers over the dome.
_ctf_trophy_art() {
cat <<'ART'
              .:=+*#%%%%#*=:.
          .:+%@@@@@@@@@@@@@@%+..
        .:*@@@@@@@@@@@@@@@@@@@@+..
       .-@@@@@@@@@@@@@@@@@@@@@@@%:
       :@@@@@@@@@@@@@@@@@@@@@@@@@%-.
       %@@@@@@@@@@@@@@@@@@@@@@@@@@@:.
     .:@@@@@@@@*##%%%%%%###**++==-*#.
     .-@@@@@@@@...               .:%-
     .:@@@@@@@@%..               ..%=
     ..%@@@@@@@@*.            ...::%+
       +@@@@@+:............   -++::%=
     ..-@@@@@-..:==+==+++:. .:=+*+-*#..
     .*%:..+@-...-==+@@@+-. .#.:+-.-@:.
     .%+. .:%:............. .*-... .%=.
     .:@=...*:.       ........*... .#*.
     ..:%=. -..       ..=::...:+:. .#*.
       .:#*....       ..:=#%+-%#:. .%+.
        ..=%@-.      .*@@@@@@@@%@=.:@-.
            -%-.     #@@@*::::##==.*#
            .:@=..   .#-.:++++*+#@@#.
              .##... .:@+:.*@@%%@@*.
               .=%*-...#@@@@@@@@@#:.
                 .=#@%#%@@@@@@@@%-..
                   ..-=*#%%%%%*=..
ART
}

# The victory screen: gold vertical fade + animated reveal + a champion flourish.
ctf_victory() {
  local -a art; mapfile -t art < <(_ctf_trophy_art)
  local n=${#art[@]} i s maxw=0
  for ((i=0; i<n; i++)); do s="$(_ctf_rstrip "${art[i]}")"; (( ${#s} > maxw )) && maxw=${#s}; done
  local target=70
  local pad=$(( (target - maxw) / 2 )); (( pad < 0 )) && pad=0

  # gold vertical fade: bright gold (top) -> deep amber (bottom)
  local tr=255 tg=240 tb=170 br=176 bg=110 bb=20
  local denom=$(( n>1 ? n-1 : 1 )) r g b
  local tty=0; [ -t 1 ] && tty=1

  ui_clear; printf '\n'
  for ((i=0; i<n; i++)); do                       # animated fade-in, line by line
    r=$(( tr + (br-tr)*i/denom )); g=$(( tg + (bg-tg)*i/denom )); b=$(( tb + (bb-tb)*i/denom ))
    printf '%*s%s%s%s\n' "$pad" "" "$(ui_fg "$r" "$g" "$b")" "$(_ctf_rstrip "${art[i]}")" "$(ui_reset)"
    (( tty )) && sleep 0.03
  done
  (( tty )) && printf '\a'                         # a little fanfare

  # FLAWLESS if no points were lost to hints, otherwise CHAMPION.
  local title="C H A M P I O N"
  [[ "$(state_total_points)" == "$(state_total_available)" ]] && title="F L A W L E S S   V I C T O R Y"

  printf '\n'
  _ctf_center "$target" "$(ui_fg 255 236 140)$T_BOLD" "·  ˚  ✦   ${title}   ✦  ˚  ·"
  printf '\n'
  _ctf_center "$target" "$(ui_fg 255 224 130)$T_BOLD" \
    "$(state_total_points) / $(state_total_available) points   ·   ${#CHALLENGE_ORDER[@]}/${#CHALLENGE_ORDER[@]} rooms cleared"
  _ctf_type   "$target" "$(ui_fg 214 178 90)" \
    "player: ${CTF_PROFILE:-player}  —  you cleared the entire CoLab CTF range."
  _ctf_center "$target" "$T_DIM" "cleared $(date '+%b %d, %Y · %H:%M')"
  printf '\n'
  _ctf_center "$target" "$T_DIM" "[enter] return"
  read -r _ || true
}

# ---- "Complete CTF" FINAL SCORE screen (retro-arcade) -----------------------
# Shown on demand from the menu ("Complete CTF"), at ANY completion level, so the
# instructor can read the player's final score off the screen. Arcade styling:
# a big block "FINAL SCORE" banner, the score as a padded counter, a letter RANK,
# and a per-room breakdown.
ctf_final_score() {
  ui_clear
  local total avail cap n pct rank rcol
  total="$(state_total_points)"; avail="$(state_total_available)"
  cap="$(state_captured_count)"; n="${#CHALLENGE_ORDER[@]}"
  pct=0; (( avail > 0 )) && pct=$(( total * 100 / avail ))
  if   (( pct >= 90 )); then rank="S"; rcol="$(ui_fg 255 215 0)"
  elif (( pct >= 75 )); then rank="A"; rcol="$T_GREEN"
  elif (( pct >= 60 )); then rank="B"; rcol="$T_CYAN"
  elif (( pct >= 40 )); then rank="C"; rcol="$T_YELLOW"
  else                       rank="D"; rcol="$T_RED"; fi

  printf '\n\n'
  local mag; mag="$(ui_fg 236 110 220)"
  while IFS= read -r line; do printf '    %s%s%s%s\n' "$T_BOLD" "$mag" "$line" "$T_RESET"; done <<'ART'
███████ ██ ███    ██  █████  ██      ███████  ██████  ██████  ██████  ███████
██      ██ ████   ██ ██   ██ ██      ██      ██      ██    ██ ██   ██ ██
█████   ██ ██ ██  ██ ███████ ██      ███████ ██      ██    ██ ██████  █████
██      ██ ██  ██ ██ ██   ██ ██           ██ ██      ██    ██ ██   ██ ██
██      ██ ██   ████ ██   ██ ███████ ███████  ██████  ██████  ██   ██ ███████
ART
  printf '\n'
  printf '        %s%sSCORE  %05d%s %s/ %d%s        %sRANK %s%s%s        %sROOMS %s%d/%d%s\n\n' \
    "$T_BOLD" "$T_YELLOW" "$total" "$T_RESET" "$T_DIM" "$avail" "$T_RESET" \
    "$T_DIM" "$rcol$T_BOLD" "$rank" "$T_RESET" \
    "$T_DIM" "$T_GREEN" "$cap" "$n" "$T_RESET"
  printf '        %splayer: %s%s%s   ·   %s%s\n\n' \
    "$T_DIM" "$T_BOLD$T_WHITE" "${CTF_PROFILE:-player}" "$T_RESET$T_DIM" "$(date '+%b %d, %Y · %H:%M')" "$T_RESET"

  local id i=0 mark pts
  for id in "${CHALLENGE_ORDER[@]}"; do
    i=$(( i + 1 ))
    if state_is_captured "$id"; then mark="${T_GREEN}✓${T_RESET}"; pts="$(state_field "$id" 3)"
    else mark="${T_SLATE}·${T_RESET}"; pts="0"; fi
    printf '      %s %s[%2d]%s %-50s %s%4s%s / %-4s\n' \
      "$mark" "$T_CYAN" "$i" "$T_RESET" "${CH_TITLE[$id]}" \
      "$T_BOLD$T_YELLOW" "$pts" "$T_RESET" "${CH_POINTS[$id]}"
  done
  printf '\n'
  printf '    %s%s>>> FINAL SCORE:  %d / %d   —   RANK %s   <<<%s\n\n' \
    "$T_BOLD" "$T_WHITE" "$total" "$avail" "$rank" "$T_RESET"
  printf '    %s[enter] return to the menu%s ' "$T_DIM" "$T_RESET"
  read -r _ || true
}
