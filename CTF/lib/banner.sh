#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — wordmark banner
#  Renders ONLY the "CoLab CTF" wordmark (no flag/hill graphic).
#   • "CoLab" in a vertical gradient of blues (navy/cyan theme)
#   • "CTF"   in a vertical gradient of reds
#  Prefers figlet "ANSI Shadow" (two separate calls, joined with a gap); falls
#  back to hardcoded blocks. Each word's lines are colorized FIRST, then joined,
#  so blue never bleeds into red. 24-bit truecolor with 256-color fallback
#  (handled by ui_fg / ui_reset in ui.sh).
# =============================================================================

# ---- Per-line palettes (line 1 = lightest/top, line 6 = deepest/bottom) ------
BANNER_BLUE_R=(147  96  59  37  29  30)
BANNER_BLUE_G=(197 165 130  99  78  64)
BANNER_BLUE_B=(253 250 246 235 216 175)

BANNER_RED_R=(252 248 239 220 185 153)
BANNER_RED_G=(165 113  68  38  28  27)
BANNER_RED_B=(165 113  68  38  28  27)

# Green gradient for the post-boot "READY" banner (top light → bottom deep).
BANNER_GREEN_R=(167 133 110  74  54  40)
BANNER_GREEN_G=(243 236 230 222 196 168)
BANNER_GREEN_B=(208 190 170 128 110  92)

# ---- Hardcoded fallback blocks ----------------------------------------------
_banner_hardcoded_colab() {
cat <<'EOF'
 ██████╗ ██████╗ ██╗      █████╗ ██████╗
██╔════╝██╔═══██╗██║     ██╔══██╗██╔══██╗
██║     ██║   ██║██║     ███████║██████╔╝
██║     ██║   ██║██║     ██╔══██║██╔══██╗
╚██████╗╚██████╔╝███████╗██║  ██║██████╔╝
 ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝
EOF
}
_banner_hardcoded_ctf() {
cat <<'EOF'
 ██████╗████████╗███████╗
██╔════╝╚══██╔══╝██╔════╝
██║        ██║   █████╗
██║        ██║   ██╔══╝
╚██████╗   ██║   ██║
 ╚═════╝   ╚═╝   ╚═╝
EOF
}

_banner_hardcoded_ready() {
cat <<'EOF'
██████╗ ███████╗ █████╗ ██████╗ ██╗   ██╗
██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝
██████╔╝█████╗  ███████║██║  ██║ ╚████╔╝
██╔══██╗██╔══╝  ██╔══██║██║  ██║  ╚██╔╝
██║  ██║███████╗██║  ██║██████╔╝   ██║
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝    ╚═╝
EOF
}

# Public: the gradient-green "READY" banner for the post-boot go-screen.
banner_ready() {
  local -a r; mapfile -t r < <(_banner_hardcoded_ready)
  _banner_trim_blank r
  local i bi n=${#r[@]}
  printf '\n'
  for (( i=0; i<n; i++ )); do
    bi=$i; (( bi >= ${#BANNER_GREEN_R[@]} )) && bi=$(( ${#BANNER_GREEN_R[@]} - 1 ))
    printf '  %s%s%s\n' \
      "$(ui_fg "${BANNER_GREEN_R[$bi]}" "${BANNER_GREEN_G[$bi]}" "${BANNER_GREEN_B[$bi]}")" "${r[$i]}" "$(ui_reset)"
  done
  printf '\n'
}

# Drop trailing blank / whitespace-only lines from a named array.
_banner_trim_blank() {
  local -n _arr=$1
  while (( ${#_arr[@]} > 0 )); do
    local last="${_arr[$(( ${#_arr[@]} - 1 ))]}"
    [[ "$last" =~ ^[[:space:]]*$ ]] || break
    unset '_arr[$(( ${#_arr[@]} - 1 ))]'
  done
}

# Column width (character count, correct for single-codepoint box glyphs in a
# UTF-8 locale) of the widest line in a named array.
_banner_maxwidth() {
  local -n _arr=$1; local w=0 line
  for line in "${_arr[@]}"; do (( ${#line} > w )) && w=${#line}; done
  printf '%d' "$w"
}

# Right-pad a string to N display columns using ASCII spaces (byte==char),
# padding by CHARACTER count so multibyte glyphs don't skew the width.
_banner_pad() { # string width
  local s="$1" width="$2" need pad=""
  need=$(( width - ${#s} ))
  (( need > 0 )) && pad="$(printf '%*s' "$need" '')"
  printf '%s%s' "$s" "$pad"
}

# ---- Public: print the wordmark ---------------------------------------------
banner_wordmark() {
  local -a colab ctf
  local used_figlet="no"

  if command -v figlet >/dev/null 2>&1; then
    local c1 c2
    c1="$(figlet -f "ANSI Shadow" -w 400 "CoLab" 2>/dev/null || true)"
    c2="$(figlet -f "ANSI Shadow" -w 400 "CTF"   2>/dev/null || true)"
    if [[ -n "$c1" && -n "$c2" ]]; then
      mapfile -t colab <<< "$c1"
      mapfile -t ctf   <<< "$c2"
      used_figlet="yes"
    fi
  fi
  if [[ "$used_figlet" == "no" ]]; then
    mapfile -t colab < <(_banner_hardcoded_colab)
    mapfile -t ctf   < <(_banner_hardcoded_ctf)
  fi

  _banner_trim_blank colab
  _banner_trim_blank ctf

  local n=${#colab[@]}
  (( ${#ctf[@]} > n )) && n=${#ctf[@]}
  local cwidth; cwidth="$(_banner_maxwidth colab)"

  printf '\n'
  local i bi bl rl padded
  for (( i=0; i<n; i++ )); do
    bi=$i; (( bi >= ${#BANNER_BLUE_R[@]} )) && bi=$(( ${#BANNER_BLUE_R[@]} - 1 ))
    bl="${colab[$i]:-}"
    rl="${ctf[$i]:-}"
    padded="$(_banner_pad "$bl" "$cwidth")"
    # Colorize each word's line independently, THEN join with a small gap.
    printf '  %s%s%s   %s%s%s\n' \
      "$(ui_fg "${BANNER_BLUE_R[$bi]}" "${BANNER_BLUE_G[$bi]}" "${BANNER_BLUE_B[$bi]}")" "$padded" "$(ui_reset)" \
      "$(ui_fg "${BANNER_RED_R[$bi]}"  "${BANNER_RED_G[$bi]}"  "${BANNER_RED_B[$bi]}")"  "$rl"     "$(ui_reset)"
  done
  printf '\n'
  printf '  %sGamified training range · flags sourced from our engagement findings%s\n\n' \
    "$T_DIM$T_SLATE" "$T_RESET"
}
