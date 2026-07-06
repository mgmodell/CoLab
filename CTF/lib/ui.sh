#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — UI library
#  Truecolor / 256-color detection, navy/cyan theme, gradient + box helpers.
#  Sourced by ctf.sh and the challenge modules. No side effects on source.
# =============================================================================

# ---- Color capability detection ---------------------------------------------
# CTF_COLOR: "truecolor" | "256" | "none"
ui_detect_color() {
  if [[ "${NO_COLOR:-}" != "" ]] || [[ ! -t 1 ]]; then
    CTF_COLOR="none"; return
  fi
  case "${COLORTERM:-}" in
    truecolor|24bit) CTF_COLOR="truecolor"; return ;;
  esac
  # Fall back to 256 if the terminal advertises it.
  local colors
  colors="$(tput colors 2>/dev/null || echo 0)"
  if [[ "$colors" -ge 256 ]]; then CTF_COLOR="256"; else CTF_COLOR="none"; fi
}
ui_detect_color

# ---- Truecolor -> 256 approximation -----------------------------------------
# Maps an RGB triple to the nearest xterm-256 color cube index.
ui_rgb_to_256() {
  local r=$1 g=$2 b=$3
  # 6x6x6 color cube starts at index 16.
  local ri gi bi
  ri=$(( r * 5 / 255 )); gi=$(( g * 5 / 255 )); bi=$(( b * 5 / 255 ))
  echo $(( 16 + 36 * ri + 6 * gi + bi ))
}

# fg RGB -> escape (respects color capability)
ui_fg() {
  case "$CTF_COLOR" in
    truecolor) printf '\e[38;2;%d;%d;%dm' "$1" "$2" "$3" ;;
    256)       printf '\e[38;5;%dm' "$(ui_rgb_to_256 "$1" "$2" "$3")" ;;
    *)         : ;;
  esac
}
ui_reset() { [[ "$CTF_COLOR" == "none" ]] || printf '\e[0m'; }

# Wrap a string in an RGB fg color + reset.
ui_paint() { # r g b text...
  local r=$1 g=$2 b=$3; shift 3
  printf '%s%s%s' "$(ui_fg "$r" "$g" "$b")" "$*" "$(ui_reset)"
}

# ---- Named theme colors (navy / cyan) ---------------------------------------
if [[ "$CTF_COLOR" != "none" ]]; then
  T_RESET=$'\e[0m'; T_BOLD=$'\e[1m'; T_DIM=$'\e[2m'; T_ITAL=$'\e[3m'
  T_CYAN="$(ui_fg 34 211 238)"
  T_SKY="$(ui_fg 125 211 252)"
  T_NAVY="$(ui_fg 30 64 175)"
  T_BLUE="$(ui_fg 59 130 246)"
  T_SLATE="$(ui_fg 148 163 184)"
  T_WHITE="$(ui_fg 226 232 240)"
  T_GREEN="$(ui_fg 74 222 128)"
  T_YELLOW="$(ui_fg 250 204 21)"
  T_RED="$(ui_fg 248 113 113)"
  T_AMBER="$(ui_fg 251 146 60)"
else
  T_RESET=''; T_BOLD=''; T_DIM=''; T_ITAL=''
  T_CYAN=''; T_SKY=''; T_NAVY=''; T_BLUE=''; T_SLATE=''
  T_WHITE=''; T_GREEN=''; T_YELLOW=''; T_RED=''; T_AMBER=''
fi

# ---- Difficulty accent colors -----------------------------------------------
ui_difficulty_color() { # difficulty -> theme var
  case "$1" in
    Easy)     printf '%s' "$T_GREEN" ;;
    Medium)   printf '%s' "$T_YELLOW" ;;
    Hard)     printf '%s' "$T_AMBER" ;;
    Critical) printf '%s' "$T_RED" ;;
    *)        printf '%s' "$T_SLATE" ;;
  esac
}

# ---- Box / rule helpers -----------------------------------------------------
UI_WIDTH=66

ui_rule() { # optional color var
  local col="${1:-$T_NAVY}"
  printf '%s' "$col"; printf '─%.0s' $(seq 1 "$UI_WIDTH"); printf '%s\n' "$T_RESET"
}

ui_box_top()    { printf '%s╭%s─%.0s%s╮%s\n' "$T_CYAN" "" $(seq 1 "$UI_WIDTH") "" "$T_RESET" 2>/dev/null || \
                  { printf '%s╭' "$T_CYAN"; printf '─%.0s' $(seq 1 "$UI_WIDTH"); printf '╮%s\n' "$T_RESET"; }; }
ui_box_bottom() { printf '%s╰' "$T_CYAN"; printf '─%.0s' $(seq 1 "$UI_WIDTH"); printf '╯%s\n' "$T_RESET"; }

# Centered title line inside a cyan box.
ui_box_title() { # text
  local text="$1" pad_total pad_l pad_r
  pad_total=$(( UI_WIDTH - ${#text} ))
  (( pad_total < 0 )) && pad_total=0
  pad_l=$(( pad_total / 2 )); pad_r=$(( pad_total - pad_l ))
  printf '%s│%s%*s%s%s%s%*s%s│%s\n' \
    "$T_CYAN" "$T_RESET" "$pad_l" "" "$T_BOLD$T_SKY" "$text" "$T_RESET" "$pad_r" "" "$T_CYAN" "$T_RESET"
}

ui_clear() { [[ -t 1 ]] && printf '\e[2J\e[H' || true; }

# Simple key/value line
ui_kv() { # key value [valuecolor]
  local key="$1" val="$2" col="${3:-$T_WHITE}"
  printf '  %s%-18s%s %s%s%s\n' "$T_SLATE" "$key" "$T_RESET" "$col" "$val" "$T_RESET"
}

# Vertical gradient helper: given parallel R/G/B arrays and an array of text
# lines, print each line colored by its row index. Used by banner.sh but kept
# here so any multi-line block can be gradient-painted.
ui_gradient_block() { # name_of_lines_array  name_of_r  name_of_g  name_of_b
  local -n _lines=$1; local -n _r=$2; local -n _g=$3; local -n _b=$4
  local i n=${#_lines[@]} ri
  for (( i=0; i<n; i++ )); do
    # Clamp to last defined shade if the block is taller than the palette.
    ri=$i; (( ri >= ${#_r[@]} )) && ri=$(( ${#_r[@]} - 1 ))
    printf '%s%s%s\n' "$(ui_fg "${_r[$ri]}" "${_g[$ri]}" "${_b[$ri]}")" "${_lines[$i]}" "$(ui_reset)"
  done
}
