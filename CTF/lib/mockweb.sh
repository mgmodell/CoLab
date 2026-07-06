#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — mock request layer
#  In simulation mode (no podman on host) each challenge is still fully
#  solvable: the target is a local mock reached via the `colab-http` client,
#  which dispatches into the challenge's own handler function. The handler
#  contains the deliberate vulnerability, so exploiting it really yields the
#  flag. Request/response parsing helpers live here; route logic lives in each
#  challenge module (keeps challenges modular & self-contained).
#
#  colab-http usage (curl-ish):
#    colab-http METHOD PATH [-H 'Key: Val']... [-d BODY] [-b 'c=v; c2=v2'] [-q 'k=v']
# =============================================================================

# Parse client args into REQ_* globals.
mw_parse() {
  REQ_METHOD="${1:-GET}"; shift || true
  local raw="${1:-/}"; shift || true
  REQ_PATH="${raw%%\?*}"
  [[ "$raw" == *\?* ]] && REQ_QUERY="${raw#*\?}" || REQ_QUERY=""
  REQ_BODY=""; REQ_COOKIE=""; REQ_HEADERS=""
  while (( $# )); do
    case "$1" in
      -H)          REQ_HEADERS+="${2}"$'\n'; shift 2 ;;
      -d|--data)   REQ_BODY="$2"; shift 2 ;;
      -b|--cookie) REQ_COOKIE="$2"; shift 2 ;;
      -q|--query)  [[ -n "$REQ_QUERY" ]] && REQ_QUERY+="&$2" || REQ_QUERY="$2"; shift 2 ;;
      *)           shift ;;
    esac
  done
}

# Fetch a request header value (case-insensitive), e.g. mw_hdr Authorization
mw_hdr() {
  local want line k v
  want="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    k="$(printf '%s' "${line%%:*}" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
    v="${line#*:}"; v="${v# }"
    [[ "$k" == "$want" ]] && { printf '%s' "$v"; return; }
  done <<< "$REQ_HEADERS"
}

# Fetch a query-string parameter, e.g. mw_query id
mw_query() {
  local want="$1" kv k v; local -a pairs
  IFS='&' read -ra pairs <<< "$REQ_QUERY"
  for kv in "${pairs[@]}"; do
    k="${kv%%=*}"; v="${kv#*=}"
    [[ "$k" == "$want" ]] && { printf '%s' "$v"; return; }
  done
}

# Fetch a body form/JSON-ish field: matches key=value or "key":"value"
mw_field() {
  local want="$1" v
  # form style: key=value(&...)
  v="$(printf '%s' "$REQ_BODY" | tr '&' '\n' | awk -F= -v k="$want" '$1==k{sub(/^[^=]*=/,""); print; exit}')"
  if [[ -z "$v" ]]; then
    # json style: "key":"value" or "key":value
    v="$(printf '%s' "$REQ_BODY" | grep -oE "\"$want\"[[:space:]]*:[[:space:]]*(\"[^\"]*\"|[^,}]+)" | head -1 \
         | sed -E "s/\"$want\"[[:space:]]*:[[:space:]]*//; s/^\"//; s/\"$//")"
  fi
  printf '%s' "$v"
}

# Fetch a cookie value, e.g. mw_cookie session
mw_cookie() {
  local want="$1" kv k v; local -a cs
  IFS=';' read -ra cs <<< "$REQ_COOKIE"
  for kv in "${cs[@]}"; do
    kv="${kv# }"; k="${kv%%=*}"; v="${kv#*=}"
    [[ "$k" == "$want" ]] && { printf '%s' "$v"; return; }
  done
}

# Tolerant base64url decode / encode (handles missing padding and -_ alphabet).
mw_b64d() {
  local s="$1"; s="${s//-/+}"; s="${s//_//}"
  case $(( ${#s} % 4 )) in 2) s+='==';; 3) s+='=';; esac
  printf '%s' "$s" | base64 -d 2>/dev/null
}
mw_b64e() { printf '%s' "$1" | base64 2>/dev/null | tr -d '\n'; }

# Emit an HTTP-ish response: status line + optional headers (dim) + body.
mw_resp() { # status  body  [header-line...]
  local status="$1" body="$2"; shift 2 || true
  printf '%s< HTTP/1.1 %s%s\n' "${T_DIM:-}" "$status" "${T_RESET:-}"
  local h; for h in "$@"; do printf '%s< %s%s\n' "${T_DIM:-}" "$h" "${T_RESET:-}"; done
  printf '%s<%s\n%s\n' "${T_DIM:-}" "${T_RESET:-}" "$body"
}
