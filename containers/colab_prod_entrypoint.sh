#!/usr/bin/env bash
#
# Production entrypoint for the CoLab target container (security environment).
# ----------------------------------------------------------------------------
# Boots CoLab in RAILS_ENV=production under Puma, preloaded with jemalloc, in a
# way that mirrors a Heroku dyno.  Also exposes a few sub-commands so the host
# interaction script (sec_serv.sh) can drive migrations / a console / a shell.
#
# Usage (the compose CMD is "web"):
#   colab_prod_entrypoint.sh web        # boot Puma in production (default)
#   colab_prod_entrypoint.sh migrate    # create + migrate the prod DB, then exit
#   colab_prod_entrypoint.sh console    # production rails console
#   colab_prod_entrypoint.sh assets     # (re)precompile assets, then exit
#   colab_prod_entrypoint.sh bash       # interactive shell
#   colab_prod_entrypoint.sh <cmd...>   # run an arbitrary command
# ----------------------------------------------------------------------------
set -euo pipefail

APP_HOME="${APP_HOME:-/app}"
cd "${APP_HOME}"

# Make the mise-managed Ruby/Node/Yarn shims and jemalloc bin available even in
# a non-login, non-interactive shell (mise activate relies on PROMPT_COMMAND,
# which never fires here, so we set PATH directly — same pattern as the dev
# entrypoint).
export PATH="${APP_HOME}/node_modules/.bin:${HOME}/.local/share/mise/shims:${HOME}/.local/bin:${APP_HOME}/vendor/jemalloc/bin:${PATH}"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"
export RAILS_ENV="${RAILS_ENV:-production}"

# Enable jemalloc exactly the way the buildpack's .profile.d hook does: when
# JEMALLOC_ENABLED=true, preload the vendored shared library. The hook appends
# to $LD_PRELOAD, which may be unset — bind it first and relax `set -u` around
# the source so nounset doesn't abort the boot.
if [ "${JEMALLOC_ENABLED:-}" = "true" ] && [ -f "${APP_HOME}/.profile.d/jemalloc.sh" ]; then
  export LD_PRELOAD="${LD_PRELOAD:-}"
  set +u
  # shellcheck disable=SC1091
  . "${APP_HOME}/.profile.d/jemalloc.sh"
  set -u
fi

# In production Rails refuses to boot without a secret_key_base.  Real engagements
# should supply SECRET_KEY_BASE (or RAILS_MASTER_KEY) via compose; we generate an
# ephemeral one only as a last resort so the target still comes up in the sandbox.
if [ -z "${SECRET_KEY_BASE:-}" ] && [ -z "${RAILS_MASTER_KEY:-}" ]; then
  echo "WARN: neither SECRET_KEY_BASE nor RAILS_MASTER_KEY set; generating an ephemeral SECRET_KEY_BASE." >&2
  SECRET_KEY_BASE="$(mise exec -- ruby -rsecurerandom -e 'print SecureRandom.hex(64)')"
  export SECRET_KEY_BASE
fi

run() { echo "+ $*" >&2; mise exec -- "$@"; }

wait_for_db() {
  # Block until the database TCP port is open so migrate/boot don't race the db
  # container's first-time initialisation. A raw /dev/tcp check is far cheaper
  # than booting Rails on every retry. Host/port are parsed from DATABASE_URL
  # (falling back to the compose defaults).
  local db_host db_port tries="${DB_WAIT_TRIES:-60}"
  db_host="$(printf '%s' "${DATABASE_URL:-}" | sed -nE 's#^[a-z0-9+]+://[^@]*@([^:/]+).*#\1#p')"
  db_port="$(printf '%s' "${DATABASE_URL:-}" | sed -nE 's#^[a-z0-9+]+://[^@]*@[^:/]+:([0-9]+).*#\1#p')"
  db_host="${db_host:-${COLAB_DB:-db}}"
  db_port="${db_port:-${COLAB_DB_PORT:-3306}}"
  echo "Waiting for the database at ${db_host}:${db_port}..."
  for _ in $(seq 1 "${tries}"); do
    if (exec 3<>"/dev/tcp/${db_host}/${db_port}") 2>/dev/null; then
      echo "Database is up."
      return 0
    fi
    sleep 2
  done
  echo "ERROR: database did not become available in time." >&2
  return 1
}

cmd="${1:-web}"
case "${cmd}" in
  web)
    wait_for_db || true
    if [ "${RUN_DB_MIGRATE_ON_BOOT:-true}" = "true" ]; then
      echo "Applying database migrations (RUN_DB_MIGRATE_ON_BOOT=true)..."
      run bundle exec rails db:create 2>/dev/null || true   # DB may already exist
      migrated=false
      for attempt in 1 2 3 4 5; do
        if run bundle exec rails db:migrate; then migrated=true; break; fi
        echo "WARN: db:migrate attempt ${attempt} failed; retrying in 5s..." >&2
        sleep 5
      done
      [ "${migrated}" = true ] || echo "WARN: db:migrate did not succeed; continuing to boot." >&2
    fi
    echo "Starting CoLab in production mode on port ${PORT:-3000} (jemalloc: ${JEMALLOC_ENABLED:-false})"
    exec mise exec -- bundle exec puma -C config/puma.rb
    ;;
  migrate)
    wait_for_db
    run bundle exec rails db:create 2>/dev/null || true     # DB may already exist
    run bundle exec rails db:migrate
    ;;
  assets)
    SECRET_KEY_BASE_DUMMY=1 run bundle exec rails assets:precompile
    ;;
  console)
    exec mise exec -- bundle exec rails console
    ;;
  bash|sh)
    exec /bin/bash
    ;;
  *)
    exec mise exec -- "$@"
    ;;
esac
