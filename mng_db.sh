#!/bin/bash

print_help ( ) {
  echo "db_load: Script to load dev db"
  echo "Valid options:"
  echo " -l [sql dump]  Load DB from dump"
  echo " -j             Load latest dev db dump"
  echo " -d             Dump the dev db"
  echo " -k             Load current test db to test"
  echo " -t             Dump the test db"
  echo " -n             Load the blank moodle db"
  echo " -b             Load latest moodle db dump"
  echo " -m             Dump the dev moodle db"
  echo ""
  echo " -h             Show this help and terminate"

  exit 0;

}

echo "Arguments: '$@'"

if [ "$#" -lt 1 ]; then
  echo "Please specify options"
  print_help
fi

#Begin

# Resolve the project root from the script's own location so the script works
# regardless of which directory it is invoked from.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper: run a command inside the dev db container without a TTY (safe for piping).
DB_EXEC="podman compose -f ${SCRIPT_DIR}/containers/dev_env/docker-compose.yml exec -T db"

SHOW_HELP=false
LOAD=false
MOODLE=false
COUNT_OPTS=0

while getopts "jkl:htmnd" opt; do
  COUNT_OPTS=$(($COUNT_OPTS + 1))
  case $opt in
    l)
      LOAD=true
      LOAD_FILE="$OPTARG"
      ;;
    j)
      LOAD=true
      LOAD_FILE="${SCRIPT_DIR}/db/dev_db.sql"
      ;;
    k)
      $DB_EXEC mariadb colab_test_ -u test -ptest < "${SCRIPT_DIR}/db/test_db.sql"
      exit
      ;;
    d)
      $DB_EXEC mariadb-dump colab_dev -u test -ptest > "${SCRIPT_DIR}/db/dev_db.sql"
      exit
      ;;
    t)
      $DB_EXEC mariadb-dump colab_test_ -u test -ptest > "${SCRIPT_DIR}/db/test_db.sql"
      exit
      ;;
    m)
      $DB_EXEC mariadb-dump moodle -u moodle -pmoodle > "${SCRIPT_DIR}/db/moodle_db.sql"
      exit
      ;;
    n)
      LOAD=true
      MOODLE=true
      LOAD_FILE="${SCRIPT_DIR}/db/moodle_blank.sql"
      ;;
    b)
      LOAD=true
      MOODLE=true
      LOAD_FILE="${SCRIPT_DIR}/db/moodle_db.sql"
      ;;
    h|\?) #Invalid option
      SHOW_HELP=true
      ;;
  esac
done

if [ $(($COUNT_OPTS)) = 0 ]; then
  SHOW_HELP=true
fi

# Handle Command Help Request
if [ "$SHOW_HELP" = true ]; then
  print_help
  exit
fi

DB_COUNT=$($DB_EXEC mariadb-show -u test -ptest 2>/dev/null | grep -c colab_dev )
if [ "$DB_COUNT" -eq 0 ]; then
  echo "Initialise the DBs from the dev environment"
  exit
fi

# Load a sql file
if [ "$LOAD" = true ]; then
  if test -f "$LOAD_FILE"; then
    echo "Loading: $LOAD_FILE"
    if [ "$MOODLE" = false ]; then
        $DB_EXEC mariadb colab_dev -u test -ptest < $LOAD_FILE
    else
        $DB_EXEC mariadb moodle -u moodle -pmoodle < $LOAD_FILE
    fi
    echo "Loaded"
  else
    echo "File does not exist: $LOAD_FILE"
    echo "Exiting"
    exit
  fi
fi

