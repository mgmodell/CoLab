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

# The victory screen. Blue vertical gradient (light cyan → deep navy), centered.
ctf_victory() {
  local -a art; mapfile -t art < <(_ctf_trophy_art)
  local n=${#art[@]} i s maxw=0
  for ((i=0;i<n;i++)); do s="$(_ctf_rstrip "${art[i]}")"; (( ${#s} > maxw )) && maxw=${#s}; done
  local target=70
  local pad=$(( (target - maxw) / 2 )); (( pad < 0 )) && pad=0
  local tr=125 tg=211 tb=252 br=30 bg=64 bb=175 denom=$(( n>1 ? n-1 : 1 )) r g b
  ui_clear; printf '\n'
  for ((i=0;i<n;i++)); do
    r=$(( tr + (br-tr)*i/denom )); g=$(( tg + (bg-tg)*i/denom )); b=$(( tb + (bb-tb)*i/denom ))
    printf '%*s%s%s%s\n' "$pad" "" "$(ui_fg "$r" "$g" "$b")" "$(_ctf_rstrip "${art[i]}")" "$(ui_reset)"
  done
  printf '\n'
  _ctf_center "$target" "$T_BOLD$T_CYAN"  "A L L   F L A G S   C A P T U R E D"
  _ctf_center "$target" "$T_BOLD$T_YELLOW" "$(state_total_points) / $(state_total_available) points   ·   ${#CHALLENGE_ORDER[@]}/${#CHALLENGE_ORDER[@]} rooms cleared"
  _ctf_center "$target" "$T_SLATE"        "player: ${CTF_PROFILE:-player}  —  you cleared the entire CoLab CTF range."
  printf '\n'
  _ctf_center "$target" "$T_DIM"          "[enter] return"
  read -r _ || true
}
