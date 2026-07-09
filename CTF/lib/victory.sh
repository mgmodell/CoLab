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
