#!/usr/bin/env bash
# =============================================================================
#  CoLab CTF — target provisioning / reset / teardown
#
#  ISOLATION GUARANTEE
#   • Real engine path (podman/docker, opt-in via CTF_LIVE_PODMAN=1): every
#     target attaches ONLY to an --internal network (colab_ctf_net) with NO
#     host port publishing, so challenges are reachable solely from the lab's
#     pentest container — never the host or outside world, and never real
#     CoLab infrastructure.
#   • By default the launcher does NOT execute container commands (so it can't
#     hang on a stopped podman machine and is safe to run anywhere). It PRINTS
#     the exact podman commands the real lab would run and serves an offline,
#     network-free mock target under ctf/state/ — which is what the flag-capture
#     logic runs against. Set CTF_LIVE_PODMAN=1 inside the real lab to execute.
# =============================================================================

if command -v podman >/dev/null 2>&1;   then PV_ENGINE="podman"
elif command -v docker >/dev/null 2>&1; then PV_ENGINE="docker"
else                                          PV_ENGINE="sim"; fi

# Live containers only when explicitly enabled AND an engine exists.
if [[ "${CTF_LIVE_PODMAN:-0}" == "1" && "$PV_ENGINE" != "sim" ]]; then
  PV_LIVE=1
else
  PV_LIVE=0
fi

PV_NET="colab_ctf_net"

pv_target_dir() { printf '%s/state/targets/%s' "$CTF_HOME" "$1"; }
pv_work_dir()   { printf '%s/state/work/%s'    "$CTF_HOME" "$1"; }

# Print a command as the real-lab recipe (dim).
pv_note() { printf '   %s$ %s%s\n' "${T_DIM:-}" "$*" "${T_RESET:-}"; }

# Run a container command if live, else just show it.
pv_run() {
  if [[ "$PV_LIVE" == "1" ]]; then
    ( eval "$*" ) >/dev/null 2>&1 || true
  else
    pv_note "$*"
  fi
}

provision_engine_line() {
  if [[ "$PV_LIVE" == "1" ]]; then
    printf '  %s●%s engine: %s%s (live)%s  ·  --internal net · no host ports\n' \
      "$T_GREEN" "$T_RESET" "$T_WHITE" "$PV_ENGINE" "$T_RESET"
  elif [[ "$PV_ENGINE" != "sim" ]]; then
    printf '  %s●%s engine: %s%s detected%s  ·  showing real-lab commands · offline mock is the live target\n' \
      "$T_YELLOW" "$T_RESET" "$T_WHITE" "$PV_ENGINE" "$T_RESET"
    printf '     %s(export CTF_LIVE_PODMAN=1 in the lab to run real containers)%s\n' "$T_DIM" "$T_RESET"
  else
    printf '  %s●%s engine: %ssimulation%s  ·  no engine on host · offline local target\n' \
      "$T_YELLOW" "$T_RESET" "$T_WHITE" "$T_RESET"
  fi
}

# Create the isolated internal network (real engines only).
provision_net() {
  [[ "$PV_ENGINE" == "sim" ]] && return 0
  pv_run "$PV_ENGINE network create --internal $PV_NET"
}

# Clean a single challenge's target + working sandbox (replayable).
provision_reset() {
  local id="$1"
  [[ "$PV_ENGINE" != "sim" ]] && pv_run "$PV_ENGINE rm -f colab_ctf_${id//-/_}"
  rm -rf "$(pv_target_dir "$id")" "$(pv_work_dir "$id")"
  mkdir -p "$(pv_target_dir "$id")" "$(pv_work_dir "$id")"
}

# Full teardown of all challenge targets + the internal network.
provision_teardown_all() {
  local id
  for id in "${CHALLENGE_ORDER[@]}"; do
    [[ "$PV_ENGINE" != "sim" ]] && pv_run "$PV_ENGINE rm -f colab_ctf_${id//-/_}"
  done
  rm -rf "$CTF_HOME/state/targets" "$CTF_HOME/state/work"
  [[ "$PV_ENGINE" != "sim" ]] && pv_run "$PV_ENGINE network rm $PV_NET"
  return 0
}

# Install the per-challenge `colab-http` client into the working dir. It
# dispatches back into the challenge handler via the CTF launcher.
provision_install_http() {
  local id="$1" work; work="$(pv_work_dir "$id")"
  cat > "$work/colab-http" <<EOF
#!/usr/bin/env bash
# colab-http — request client for the provisioned CoLab CTF target [$id].
# Lab-isolated offline mock. Usage:
#   colab-http METHOD PATH [-H 'Key: Val']... [-d BODY] [-b 'c=v'] [-q 'k=v']
exec bash "$CTF_HOME/ctf.sh" __serve "$id" "\$@"
EOF
  chmod +x "$work/colab-http" 2>/dev/null || true
}

# Convenience: plant a file inside the challenge target dir.
pv_plant() { # id relpath content
  local id="$1" rel="$2" content="$3" dst
  dst="$(pv_target_dir "$id")/$rel"
  mkdir -p "$(dirname "$dst")"
  printf '%s' "$content" > "$dst"
}
