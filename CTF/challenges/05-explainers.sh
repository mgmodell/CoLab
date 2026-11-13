#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — per-room explainer panels  (ADDITIVE — edits nothing existing)
#
#  Adds an optional "explainer" card to a room's briefing screen, in the navy/
#  cyan house theme (same T_CYAN border, T_SKY title and T_WHITE body used by
#  lib/ui.sh and the rest of the briefing). The card is placed directly under
#  the "Your objective" block, above the Vulnerability/Endpoint details.
#
#  Content is keyed by challenge id in EXPLAINER_TITLE / EXPLAINER_BODY below,
#  so NOTHING in 00-common.sh or the individual challenge files is modified.
#  This file wraps challenge_briefing: it runs the original (untouched) and
#  splices the card into its output. Rooms with no explainer are unaffected.
# =============================================================================

declare -A EXPLAINER_TITLE EXPLAINER_BODY

# ---- IDOR (easy) ------------------------------------------------------------
EXPLAINER_TITLE[easy-idor]="What is IDOR"
EXPLAINER_BODY[easy-idor]="IDOR stands for “Insecure Direct Object Reference,” and the grade-record version works like this. Picture a school website where you log in to see your grades, and the web address ends in something like “student=1042,” your student number. An IDOR problem exists when the website checks that you’re logged in but never checks whether the record you’re asking for actually belongs to you. If you change that number to 1043, the site hands over a classmate’s grades as if they were yours. It’s like a school office that asks to see a student ID before giving out report cards, but never checks whether the name on the ID matches the name on the report card it hands over. The fix is simple in principle: every time someone asks for a record, the website should confirm it belongs to that person, or that they have a good reason to see it, such as being the teacher."

# ---- text helpers (unicode-aware: count characters, not bytes) ---------------
_exp_pad() {  # text width  -> text padded with spaces to `width` display cols
  local t="$1" w="$2" len pad
  len=${#t}; pad=$(( w - len )); (( pad < 0 )) && pad=0
  printf '%s%*s' "$t" "$pad" ""
}

_exp_wrap() {  # text width  -> word-wrapped lines (one per line)
  local text="$1" w="$2" line="" word
  for word in $text; do
    if [[ -z "$line" ]]; then
      line="$word"
    elif (( ${#line} + 1 + ${#word} <= w )); then
      line="$line $word"
    else
      printf '%s\n' "$line"; line="$word"
    fi
    while (( ${#line} > w )); do
      printf '%s\n' "${line:0:w}"; line="${line:w}"
    done
  done
  [[ -n "$line" ]] && printf '%s\n' "$line"
}

# Build the boxed card lines into EXP_PANEL[] (house cyan / sky / white theme).
_exp_build() {  # title body textwidth
  local title="$1" body="$2" tw="$3" bar line
  EXP_PANEL=()
  bar="$(printf '─%.0s' $(seq 1 $(( tw + 2 )) ))"
  EXP_PANEL+=( "${T_CYAN}╭${bar}╮${T_RESET}" )
  EXP_PANEL+=( "${T_CYAN}│${T_RESET} ${T_BOLD}${T_SKY}$(_exp_pad "$title" "$tw")${T_RESET} ${T_CYAN}│${T_RESET}" )
  EXP_PANEL+=( "${T_CYAN}├${bar}┤${T_RESET}" )
  while IFS= read -r line; do
    EXP_PANEL+=( "${T_CYAN}│${T_RESET} ${T_WHITE}$(_exp_pad "$line" "$tw")${T_RESET} ${T_CYAN}│${T_RESET}" )
  done < <(_exp_wrap "$body" "$tw")
  EXP_PANEL+=( "${T_CYAN}╰${bar}╯${T_RESET}" )
}

# ---- wrap challenge_briefing (original kept intact, called first) ------------
if declare -f challenge_briefing >/dev/null 2>&1 \
   && ! declare -f __orig_challenge_briefing >/dev/null 2>&1; then
  eval "__orig_$(declare -f challenge_briefing)"

  challenge_briefing() {
    local id="${1:-}"
    local title="${EXPLAINER_TITLE[$id]:-}" body="${EXPLAINER_BODY[$id]:-}"

    # Rooms without an explainer: behave exactly as before.
    if [[ -z "$body" ]]; then
      __orig_challenge_briefing "$id"
      return 0
    fi

    # Capture the original briefing, then splice the card in just below the
    # "Your objective" block (i.e. right before the Vulnerability detail line).
    local out; out="$(__orig_challenge_briefing "$id")"
    _exp_build "$title" "$body" 60

    [[ -t 1 ]] && printf '\e[2J\e[H'      # ui_clear is suppressed inside $(), redo it
    local injected=0 line pl
    while IFS= read -r line; do
      if (( ! injected )) && [[ "$line" == *Vulnerability* ]]; then
        for pl in "${EXP_PANEL[@]}"; do printf '  %s\n' "$pl"; done
        echo
        injected=1
      fi
      printf '%s\n' "$line"
    done <<< "$out"

    # Safety net: if the anchor wasn't found, append the card at the end.
    if (( ! injected )); then
      echo
      for pl in "${EXP_PANEL[@]}"; do printf '  %s\n' "$pl"; done
    fi
  }
fi
