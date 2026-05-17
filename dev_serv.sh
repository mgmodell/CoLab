#!/bin/bash

print_help ( ) {
  echo "dev_serv: Script to interact with dev server in containerized"
  echo "          environment"
  echo "Valid options:"
  echo " -s             Start the server over HTTP (cannot be combined)"
  echo " -t             Start the server over HTTPS/TLS (cannot be combined)"
  echo "                Generates a self-signed certificate in tmp/ssl/ on"
  echo "                first run.  Required for LTI Dynamic Registration,"
  echo "                Deep Linking, and Grade Push testing."
  echo " -f [features]  Specify specific features to run"
  echo ""
  echo " -p             Prepare the DB (run db:create task)"
  echo " -d             Migrate the DB"
  echo " -c             Run the rails console (then terminate)"
  echo " -q [db]        Open mysql terminal to 'colab' or 'moodle'"
  echo " -m [task]      Run a migratify task (assumes -m)"
  echo " -e [task]      Run a tEsting task (then terminate;"
  echo "                assumes -m)"
  echo " -a [task]      Run a admin task (then terminate;"
  echo "                assumes -m)"
  echo ""
  echo " -h             Show this help and terminate"

  exit 0;

}

if [ "$container" = 'podman' ]; then
  # We're in a Docker container, so we're good!
  echo "Arguments: '$@'"
else
  echo "These scripts only function properly inside a Docker"
  echo "container and we're currently not running inside one."
  echo "-----------"
  print_help
fi


if [ "$#" -lt 1 ]; then
  echo "Please specify options"
  print_help
fi


# Set up run context
COLAB_DB=db
COLAB_DB_PORT=3306

SHOW_HELP=false
MIGRATE=false
PREPARE=true
RUN_TASK_M=false
RUN_TASK_E=false
RUN_TASK_A=false
FEATURE=false
LOAD=false
STARTUP=false
STARTUP_TLS=false

# Set up a variable for the container
export HOSTNAME=$(hostname -s)

while getopts "a:cf:q:dtsm:e:ph" opt; do
  case $opt in
    q)
      if [[ $OPTARG == "moodle" ]]; then
        mysql moodle --host db -u moodle -pmoodle --protocol=TCP --port=3306
      else
        mysql colab_dev --host db -u test -ptest --protocol=TCP --port=3306
      fi
      exit
      ;;
    f)
      echo "Feature: $OPTARG"
      FEATURE=true
      FEATURES=$OPTARG
      MIGRATE=true
      ;;
    c)
      rails console
      exit
      ;;
    s)
      STARTUP=true
      ;;
    t)
      STARTUP_TLS=true
      ;;
    a)
      RUN_TASK_A=true
      RUN_TASK_A_NAME=$OPTARG
      MIGRATE=true
      ;;
    e)
      RUN_TASK_E=true
      RUN_TASK_E_NAME=$OPTARG
      MIGRATE=true
      ;;
    m)
      MIGRATE=true
      RUN_TASK_M=true
      RUN_TASK_M_NAME=$OPTARG
      ;;
    d)
      MIGRATE=true
      ;;
    h|\?) #Invalid option
      SHOW_HELP=true
      ;;
    p)
      PREPARE=true
      ;;
  esac
done

# Handle Command Help Request
if [ "$SHOW_HELP" = true ]; then
  print_help
fi

if [ "$PREPARE" = true ]; then
  echo "Preparing (creating) the DB..."
  rails db:create COLAB_DB=db COLAB_DB_PORT=3306
fi


# Run a migratify task
if [ "$RUN_TASK_M" = true ]; then
  echo 'Migratify Task'
  rails migratify:$RUN_TASK_M_NAME COLAB_DB=db COLAB_DB_PORT=3306
fi

# Migrate the DB
if [ "$MIGRATE" = true ]; then
  echo "Migrating the DB..."
  rails db:migrate COLAB_DB=db COLAB_DB_PORT=3306
fi

# Run a testing task
if [ "$RUN_TASK_E" = true ]; then
  echo 'Testing Task'
  rails testing:$RUN_TASK_E_NAME COLAB_DB=db COLAB_DB_PORT=3306
fi

# Run an admin task
if [ "$RUN_TASK_A" = true ]; then
  echo 'Admin Task'
  rails admin:$RUN_TASK_A_NAME COLAB_DB=db COLAB_DB_PORT=3306
fi

# Test a feature
if [ "$FEATURE" = true ]; then
  echo 'Testing Feature'
  rails cucumber DRIVER=docker FEATURE=$FEATURES COLAB_DB=db COLAB_DB_PORT=3306
fi

# Returns true (exit 0) when overmind should be skipped:
#   1. Native Windows shell (MSYS2/Git Bash/Cygwin) — uname reports MINGW/CYGWIN/MSYS
#   2. Inside a container hosted on Windows (Podman/Docker) — filesystem type is v9fs
# WSL reports "Linux" via uname and uses a normal ext4/overlay filesystem, so it
# continues to use overmind.
skip_overmind() {
  case "$(uname -s)" in
    MINGW*|CYGWIN*|MSYS*) return 0 ;;
  esac
  [ "$(stat -f -c %T . 2>/dev/null)" = "v9fs" ]
}

# On Windows-hosted containers (v9fs), native Node optional dependencies can be
# stale or missing if node_modules was seeded from a different platform. Ensure
# @rspack/binding can load before starting the dev server processes.
ensure_rspack_binding() {
  [ "$(stat -f -c %T . 2>/dev/null)" = "v9fs" ] || return 0

  if node -e "require('@rspack/binding')" >/dev/null 2>&1; then
    return 0
  fi

  echo "Detected missing/incompatible @rspack/binding native module; reinstalling JS dependencies..."
  yarn install --check-files

  if ! node -e "require('@rspack/binding')" >/dev/null 2>&1; then
    echo "ERROR: @rspack/binding is still unavailable after reinstall." >&2
    echo "Try removing your node_modules volume with your container runtime" >&2
    echo "(for example Docker/Podman) and then:" >&2
    echo "  Dev Containers: Rebuild and Reopen in Container." >&2
    return 1
  fi
}

# Start the server (HTTP)
if [ "$STARTUP" = true ]; then
  if [ "$STARTUP_TLS" = true ]; then
    echo "Error: -s and -t cannot be combined. Use -s for HTTP or -t for HTTPS."
    print_help
  fi
  ensure_rspack_binding || exit 1
  if ! skip_overmind && command -v overmind &> /dev/null; then
    overmind start -f Procfile.dev
  elif command -v foreman &> /dev/null; then
    foreman start -f Procfile.dev
  else
    echo "ERROR: Neither 'overmind' nor 'foreman' is installed." >&2
    echo "  Install overmind: https://github.com/DarthSim/overmind" >&2
    echo "  Install foreman:  gem install foreman" >&2
    exit 1
  fi
fi

# Start the server (HTTPS – required for LTI testing)
if [ "$STARTUP_TLS" = true ]; then
  HTTPS_PORT="${PORT:-3443}"
  ensure_rspack_binding || exit 1
  echo ""
  echo "Starting CoLab HTTPS dev server on https://app:${HTTPS_PORT}"
  echo "  LTI Dynamic Registration URL: https://app:${HTTPS_PORT}/lti/lti_connect"
  echo "  Run bin/setup_moodle_course to configure Moodle automatically."
  echo "  Activity will be logged to the console (stdout)."
  echo ""
  overmind start -f Procfile.dev-https
fi
