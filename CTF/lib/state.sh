#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — progress & scoring state
#  Source of truth: ctf/state/progress.tsv (gitignored).
#   columns: id <TAB> captured(0/1) <TAB> points_awarded <TAB> hints_used <TAB> captured_at
#  A readable progress.json snapshot is exported alongside on every change.
#  Scoring: base points per difficulty; each revealed hint reduces that
#  challenge's award, floored at 40% of base.
# =============================================================================

state_file() { printf '%s/state/progress.tsv' "$CTF_HOME"; }
state_json()  { printf '%s/state/progress.json' "$CTF_HOME"; }

state_init() {
  local f id; f="$(state_file)"; mkdir -p "$CTF_HOME/state"
  [[ -f "$f" ]] || : > "$f"
  # Ensure a row exists for every registered challenge (supports dropping in
  # new challenge definitions later without wiping existing progress).
  for id in "${CHALLENGE_ORDER[@]}"; do
    if ! awk -F'\t' -v id="$id" '$1==id{ok=1} END{exit !ok}' "$f"; then
      printf '%s\t0\t0\t0\t\n' "$id" >> "$f"
    fi
  done
  state_export_json
}

# Read column `c` (1..5) for challenge id.
state_field() { awk -F'\t' -v id="$1" -v c="$2" '$1==id{print $c; exit}' "$(state_file)"; }

state_is_captured() { [[ "$(state_field "$1" 2)" == "1" ]]; }
state_hints_used()  { local n; n="$(state_field "$1" 4)"; printf '%s' "${n:-0}"; }

# Set column `c` for id to value `v`.
state_set() {
  local id="$1" col="$2" val="$3" f tmp
  f="$(state_file)"; tmp="$(mktemp)"
  awk -F'\t' -v OFS='\t' -v id="$id" -v c="$col" -v v="$val" \
    '$1==id{$c=v} {print}' "$f" > "$tmp" && mv "$tmp" "$f"
}

# Reveal-a-hint bookkeeping: increment count, echo new total.
state_use_hint() {
  local id="$1" n
  n=$(( $(state_hints_used "$id") + 1 ))
  state_set "$id" 4 "$n"
  state_export_json
  printf '%s' "$n"
}

# Points that WOULD be awarded now, given hints already used.
state_award_value() {
  local id="$1" base pen hints award floor
  base="${CH_POINTS[$id]:-0}"; pen="${CH_HINT_PENALTY[$id]:-0}"
  hints="$(state_hints_used "$id")"
  award=$(( base - hints * pen ))
  floor=$(( base * 40 / 100 ))
  (( award < floor )) && award=$floor
  printf '%s' "$award"
}

# Mark captured. Echoes awarded points. Returns 2 if already captured.
state_capture() {
  local id="$1" award
  [[ "$(state_field "$id" 2)" == "1" ]] && return 2
  award="$(state_award_value "$id")"
  state_set "$id" 2 1
  state_set "$id" 3 "$award"
  state_set "$id" 5 "$(date '+%Y-%m-%d %H:%M:%S')"
  state_export_json
  printf '%s' "$award"
}

state_total_points()   { awk -F'\t' '{s+=$3} END{print s+0}' "$(state_file)"; }
state_captured_count() { awk -F'\t' '$2==1{c++} END{print c+0}' "$(state_file)"; }
state_total_available() {
  local id s=0; for id in "${CHALLENGE_ORDER[@]}"; do s=$(( s + ${CH_POINTS[$id]:-0} )); done
  printf '%s' "$s"
}
state_captured_at() { state_field "$1" 5; }

state_reset() {
  local id="$1"
  state_set "$id" 2 0; state_set "$id" 3 0; state_set "$id" 4 0; state_set "$id" 5 ""
  state_export_json
}
state_reset_all() {
  local id
  for id in "${CHALLENGE_ORDER[@]}"; do
    state_set "$id" 2 0; state_set "$id" 3 0; state_set "$id" 4 0; state_set "$id" 5 ""
  done
  state_export_json
}

# ---- Readable JSON snapshot -------------------------------------------------
state_export_json() {
  local f out id first=1
  f="$(state_file)"; out="$(state_json)"
  {
    printf '{\n'
    printf '  "total_points": %s,\n'    "$(state_total_points)"
    printf '  "points_available": %s,\n' "$(state_total_available)"
    printf '  "captured": %s,\n'         "$(state_captured_count)"
    printf '  "challenges": [\n'
    for id in "${CHALLENGE_ORDER[@]}"; do
      [[ $first -eq 1 ]] && first=0 || printf ',\n'
      printf '    { "id": "%s", "title": "%s", "difficulty": "%s", "captured": %s, "points": %s, "hints_used": %s, "captured_at": "%s" }' \
        "$id" "${CH_TITLE[$id]:-}" "${CH_DIFF[$id]:-}" \
        "$(state_field "$id" 2)" "$(state_field "$id" 3)" "$(state_field "$id" 4)" "$(state_field "$id" 5)"
    done
    printf '\n  ]\n}\n'
  } > "$out"
}
