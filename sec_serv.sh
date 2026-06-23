#!/bin/bash
#
# sec_serv.sh — start, stop, and interact with the CoLab security (pentest)
#               environment (containers/sec_env/docker-compose.yml).
#
# Host-side companion to dev_serv.sh: where dev_serv.sh runs *inside* the dev
# container, this script runs on the *host* (like mng_db.sh / run_tests.sh) and
# drives the engagement stack through `podman compose`.

print_help ( ) {
  echo "sec_serv: Script to interact with the CoLab security (pentest)"
  echo "          environment in containers"
  echo "Valid options:"
  echo " -u             Bring the environment Up (build if needed), detached"
  echo " -b             Build/(re)build all images"
  echo " -k             stop (Kill) running containers, keep volumes"
  echo " -r             Restart the environment"
  echo " -x             Tear the environment down (remove containers/networks)"
  echo " -X             Tear down AND remove volumes (destroys the sandbox DB)"
  echo " -s             Show Status (compose ps)"
  echo " -l             tail Logs (follow) for the whole stack"
  echo ""
  echo " -p             Open a shell in the Pentest toolbox (main interaction)"
  echo " -c             Open a rails Console on the production target"
  echo " -q             Open a mysql session on the target DB (colab_prod)"
  echo " -i             (re-)Initialise the target DB from db/dev_db.sql,"
  echo "                then run production migrations"
  echo " -e             sEed the target: rails db:seed (reference data +"
  echo "                ~185 languages) and the sandbox test users"
  echo ""
  echo " -W             Add the Windows compose override (Podman Desktop)"
  echo " -h             Show this help and terminate"

  exit 0;

}

if [ "$#" -lt 1 ]; then
  echo "Please specify options"
  print_help
fi

echo "Arguments: '$@'"

# Require a container engine on the host.
if ! command -v podman &> /dev/null; then
  echo "ERROR: 'podman' was not found on PATH." >&2
  echo "  Install Podman Desktop (https://podman-desktop.io/) and retry." >&2
  exit 1
fi

# Note (Windows Git Bash / MSYS / Cygwin): POSIX-looking *arguments* that start
# with "/" get auto-rewritten to host paths when handed to the native
# podman/compose .exe. The compose file path (-f) relies on that conversion, but
# container-internal paths must NOT be converted. We therefore avoid passing
# bare container-absolute paths as arguments — e.g. `sh -lc 'cd /app && exec
# bin/...'` instead of `/app/bin/...` — so both work without toggling conversion.

# Resolve the project root from the script's own location so it works no matter
# which directory it is invoked from (same approach as mng_db.sh).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/containers/sec_env/docker-compose.yml"
WIN_FILE="${SCRIPT_DIR}/containers/sec_env/docker-compose.windows.yml"
DB_SNAPSHOT="${SCRIPT_DIR}/db/dev_db.sql"
BOOT_MODE="${SCRIPT_DIR}/boot_mode.sh"
MODE_ENV="${SCRIPT_DIR}/containers/sec_env/.env"

# Load the selected engagement mode (PENTEST_MODE/TESTER/SESSION) so every
# `compose` call passes it into the toolbox container. boot_mode.sh writes this
# file on `-u`; here we just export whatever the last selection was (if any).
load_mode_env() {
  if [ -f "${MODE_ENV}" ]; then
    set -a; . "${MODE_ENV}"; set +a
  fi
}
load_mode_env

# Action flags
SHOW_HELP=false
UP=false
BUILD=false
STOP=false
RESTART=false
DOWN=false
DOWN_VOLUMES=false
STATUS=false
LOGS=false
SHELL_PENTEST=false
CONSOLE=false
MYSQL=false
INIT_DB=false
SEED=false
USE_WIN=false

while getopts "ubkrxXslpcqieWh" opt; do
  case $opt in
    u) UP=true ;;
    b) BUILD=true ;;
    k) STOP=true ;;
    r) RESTART=true ;;
    x) DOWN=true ;;
    X) DOWN=true; DOWN_VOLUMES=true ;;
    s) STATUS=true ;;
    l) LOGS=true ;;
    p) SHELL_PENTEST=true ;;
    c) CONSOLE=true ;;
    q) MYSQL=true ;;
    i) INIT_DB=true ;;
    e) SEED=true ;;
    W) USE_WIN=true ;;
    h|\?) SHOW_HELP=true ;;
  esac
done

if [ "$SHOW_HELP" = true ]; then
  print_help
fi

# Assemble the compose invocation (optionally with the Windows override).
COMPOSE=(podman compose -f "${COMPOSE_FILE}")
if [ "$USE_WIN" = true ]; then
  COMPOSE+=(-f "${WIN_FILE}")
fi
compose() { "${COMPOSE[@]}" "$@"; }

# The Podman engine must be reachable. The #1 post-reboot gotcha on Windows/macOS
# is a stopped Podman machine, which makes every command fail cryptically.
ensure_podman_up() {
  if ! podman info >/dev/null 2>&1; then
    echo "ERROR: cannot reach the Podman engine." >&2
    echo "  On Windows/macOS the Podman machine is often stopped after a reboot." >&2
    echo "  Start it, then re-run this script:" >&2
    echo "      podman machine start" >&2
    exit 1
  fi
}

# Ensure the stack is running before exec'ing into a container. It can stop after
# the host sleeps/reboots (Podman's restart policy doesn't always survive a
# machine restart), which makes `exec` fail with "container is not running".
# No-op when the toolbox is already up.
ensure_up() {
  local cid; cid="$(compose ps -q pentest 2>/dev/null)"
  if [ -z "${cid}" ] || [ "$(podman inspect -f '{{.State.Running}}' "${cid}" 2>/dev/null)" != "true" ]; then
    echo "Environment isn't running — starting it (this also waits for the DB)..."
    compose up -d
  fi
}

# Poll the target's health endpoint until it serves (first boot runs migrations).
wait_for_target() {
  local url="http://localhost:13000/up" tries="${1:-90}" code
  echo "Waiting for the CoLab target to become ready"
  echo "  (first boot waits for the DB and runs migrations — this can take a minute)..."
  for _ in $(seq 1 "${tries}"); do
    code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 3 "${url}" 2>/dev/null || echo 000)"
    [ "${code}" = "200" ] && return 0
    sleep 2
  done
  return 1
}

# Any action below talks to the engine.
ensure_podman_up

# Build images
if [ "$BUILD" = true ]; then
  echo "Building the security environment images..."
  compose build
fi

# Bring the stack up (compose builds any missing images automatically)
if [ "$UP" = true ]; then
  # Engagement kickoff: run the interactive mode selector BEFORE any containers
  # spin up. It writes containers/sec_env/.env (PENTEST_MODE/TESTER/SESSION),
  # a timestamped sessions/ record, and refreshes the Quick Start. Re-running
  # `-u` re-prompts (idempotent). Skip only if the selector is missing.
  if [ -f "${BOOT_MODE}" ]; then
    bash "${BOOT_MODE}"
    load_mode_env   # re-read the freshly selected mode so compose passes it in
  else
    echo "NOTE: ${BOOT_MODE} not found — starting without mode selection." >&2
  fi
  echo "Starting the security environment (detached)..."
  compose up -d
  echo ""
  if wait_for_target 90; then
    echo "  ✅ Target is UP"
    echo "     Browser / login : https://localhost:13443  (HTTPS — accept the self-signed cert)"
    echo "     Direct HTTP     : http://localhost:13000   (recon/tools; login needs the HTTPS URL)"
    echo "     In-network      : http://app:3000"
  else
    echo "  ⚠️  Target is not answering yet on http://localhost:13000."
    echo "     The DB's first-time init can be slow; wait a minute, then reload the URL."
    echo "     Inspect progress with:  ./sec_serv.sh -l    (or  ./sec_serv.sh -s )"
  fi
  echo "  Pentest toolbox     : ./sec_serv.sh -p"
  echo "  (Re-)initialise DB  : ./sec_serv.sh -i      |   Seed data: ./sec_serv.sh -e"
fi

# Restart
if [ "$RESTART" = true ]; then
  echo "Restarting the security environment..."
  compose restart
fi

# (re-)Initialise the target database
if [ "$INIT_DB" = true ]; then
  echo "Initialising the target database (colab_prod)..."
  if [ -s "${DB_SNAPSHOT}" ]; then
    echo "Loading snapshot: ${DB_SNAPSHOT}"
    compose exec -T db mariadb colab_prod -u prod -pprod < "${DB_SNAPSHOT}"
    echo "Snapshot loaded."
  else
    echo "NOTE: ${DB_SNAPSHOT} is empty or missing — skipping snapshot load."
    echo "      The schema will be created from production migrations instead."
  fi
  echo "Running production migrations on the target..."
  compose exec -T app sh -lc 'cd /app && exec bin/colab_prod_entrypoint.sh migrate'
  echo "Database initialised."
fi

# Seed the target: foundational reference data (rails db:seed) + sandbox users.
if [ "$SEED" = true ]; then
  echo "Seeding the production target — foundational data (rails db:seed)..."
  compose exec -T app sh -lc 'cd /app && RAILS_ENV=production mise exec -- bundle exec rails db:seed'
  echo "Seeding sandbox test users (db/seed_pentest_users.rb)..."
  compose exec -T app sh -lc 'cd /app && RAILS_ENV=production mise exec -- bundle exec rails runner db/seed_pentest_users.rb'
  echo "Seeding complete. Sandbox accounts (see db/seed_pentest_users.rb) can log in at https://localhost:13443."
fi

# Open a shell in the pentest toolbox (login shell -> prints the briefing)
if [ "$SHELL_PENTEST" = true ]; then
  ensure_up
  echo "Opening a shell in the pentest toolbox..."
  compose exec pentest bash -l
fi

# Open a production rails console on the target
if [ "$CONSOLE" = true ]; then
  ensure_up
  echo "Opening a production rails console on the target..."
  compose exec app sh -lc 'cd /app && exec bin/colab_prod_entrypoint.sh console'
fi

# Open a mysql session on the target DB
if [ "$MYSQL" = true ]; then
  ensure_up
  echo "Opening a mysql session on colab_prod..."
  compose exec db mariadb colab_prod -u prod -pprod
fi

# Status
if [ "$STATUS" = true ]; then
  compose ps
fi

# Logs (follow)
if [ "$LOGS" = true ]; then
  compose logs -f
fi

# Stop (keep containers/volumes)
if [ "$STOP" = true ]; then
  echo "Stopping the security environment..."
  compose stop
fi

# Tear down
if [ "$DOWN" = true ]; then
  if [ "$DOWN_VOLUMES" = true ]; then
    echo "Tearing down the security environment AND removing volumes..."
    compose down -v
  else
    echo "Tearing down the security environment..."
    compose down
  fi
fi
