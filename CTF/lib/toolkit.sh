#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — per-challenge toolkit loader
#  Preps a working directory in the (pentest) container with the relevant
#  tooling, an objective card, a progressively-revealed hints file, and a
#  post-capture writeup template. Challenge-specific helpers (sqlmap wrappers,
#  JWT/token helpers, SSRF harness, …) are installed by each challenge's
#  ch_toolkit() via toolkit_install_helper.
# =============================================================================

# Split a challenge's hints (newline-joined) into an array `HINTS`.
toolkit_load_hints() { # id ; sets HINTS[]
  local id="$1"; HINTS=()
  [[ -n "${CH_HINTS[$id]:-}" ]] && mapfile -t HINTS <<< "${CH_HINTS[$id]}"
}
toolkit_hint_count() { local -a HINTS; toolkit_load_hints "$1"; printf '%s' "${#HINTS[@]}"; }
toolkit_get_hint()   { local -a HINTS; toolkit_load_hints "$1"; printf '%s' "${HINTS[$(( $2 - 1 ))]:-}"; }

# Report which declared tools are present in this environment.
toolkit_tools_line() {
  local id="$1" tool line="" mark; local -a tools
  IFS=',' read -ra tools <<< "${CH_TOOLS[$id]:-}"
  for tool in "${tools[@]}"; do
    tool="$(printf '%s' "$tool" | tr -d ' ')"; [[ -z "$tool" ]] && continue
    if command -v "$tool" >/dev/null 2>&1; then mark="${T_GREEN}✓${T_RESET}"; else mark="${T_SLATE}○${T_RESET}"; fi
    line+="  ${mark} ${tool}"
  done
  printf '%s' "$line"
}

# Install an executable helper into the working dir.
toolkit_install_helper() { # id name content
  local id="$1" name="$2" content="$3" work; work="$(pv_work_dir "$id")"
  mkdir -p "$work"
  printf '%s\n' "$content" > "$work/$name"
  chmod +x "$work/$name" 2>/dev/null || true
}

# (Re)write the hints file, exposing ONLY hints already revealed (per state).
toolkit_write_hints() {
  local id="$1" work used i; work="$(pv_work_dir "$id")"
  used="$(state_hints_used "$id")"
  {
    echo "# Hints — ${CH_TITLE[$id]}"
    echo "# Reveal more from the challenge menu (each costs ${CH_HINT_PENALTY[$id]:-0} pts)."
    echo
    if (( used == 0 )); then
      echo "(no hints revealed yet)"
    else
      for (( i=1; i<=used; i++ )); do
        printf '%d. %s\n' "$i" "$(toolkit_get_hint "$id" "$i")"
      done
    fi
  } > "$work/HINTS.txt"
}

# Objective card dropped into the working dir.
toolkit_write_objective() {
  local id="$1" work; work="$(pv_work_dir "$id")"
  {
    echo "# ${CH_TITLE[$id]}"
    echo
    echo "Difficulty : ${CH_DIFF[$id]}   (${CH_POINTS[$id]} pts)"
    echo "OWASP      : ${CH_OWASP[$id]}"
    echo "Objective  : ${CH_OBJECTIVE[$id]}"
    echo
    echo "Client     : ./colab-http  (curl-ish; talks to the isolated target)"
    echo "Flag format: CoLab{lowercase_snake_case}"
    echo "Submit      : from the challenge menu, choose [s] submit."
  } > "$work/OBJECTIVE.txt"
}

# Post-capture scratch writeup template.
toolkit_writeup_template() {
  local id="$1" work; work="$(pv_work_dir "$id")"
  local f="$work/WRITEUP.md"
  [[ -f "$f" ]] && return 0
  cat > "$f" <<EOF
# Writeup — ${CH_TITLE[$id]}

- **Vulnerability class:** ${CH_OWASP[$id]}
- **Target / endpoint:** ${CH_ENDPOINT[$id]:-N/A}
- **Difficulty:** ${CH_DIFF[$id]}

## 1. Recon / what I noticed


## 2. Exploitation steps
1.
2.
3.

## 3. Payload / request that worked
\`\`\`
\`\`\`

## 4. Flag
CoLab{...}

## 5. Remediation
- ${CH_REMEDIATION[$id]:-}
EOF
}

# Full toolkit prep for a challenge.
toolkit_prepare() {
  local id="$1"
  mkdir -p "$(pv_work_dir "$id")"
  provision_install_http "$id"
  toolkit_write_objective "$id"
  toolkit_write_hints "$id"
  # Challenge-specific helpers.
  if declare -F "${CH_TOOLKIT[$id]}" >/dev/null 2>&1; then
    "${CH_TOOLKIT[$id]}" "$id"
  fi
}

# Print a short "your kit is ready" summary.
toolkit_summary() {
  local id="$1" work; work="$(pv_work_dir "$id")"
  printf '  %sworking dir%s  %s\n' "$T_SLATE" "$T_RESET" "$work"
  printf '  %stools%s      %s\n' "$T_SLATE" "$T_RESET" "$(toolkit_tools_line "$id")"
  printf '  %sfiles%s      ' "$T_SLATE" "$T_RESET"
  ( cd "$work" 2>/dev/null && ls -1 2>/dev/null | tr '\n' ' ' )
  printf '\n'
}
