#!/bin/bash

print_help ( ) {
  echo "db_load: Script to load dev db"
  echo "Valid options:"
  echo " -l [sql dump]  Load DB from dump"
  echo " -j             Load latest dev db dump"
  echo " -d             Dump the dev db"
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

# Set up run context
COLAB_DB=db
COLAB_DB_PORT=3306

SHOW_HELP=false
MIGRATE=false
LOAD=false
MOODLE=false
COUNT_OPTS=0

# Set up a variable for the container
export HOSTNAME=$(hostname -s)

while getopts "jl:htmnd" opt; do
  COUNT_OPTS=$(($COUNT_OPTS + 1))
  case $opt in
    l)
      LOAD=true
      LOAD_FILE="$OPTARG"
      ;;
    j)
      LOAD=true
      LOAD_FILE="db/dev_db.sql"
      ;;
    d)
      mysqldump colab_dev -u test -ptest --port=31337 > db/dev_db.sql
      exit
      ;;
    t)
      mysqldump colab_test_ -u test -ptest --port=31337 > db/test_db.sql
      exit
      ;;
    m)
      mysqldump moodle -u moodle -pmoodle --port=31337 > db/moodle_db.sql
      exit
      ;;
    n)
      LOAD=true
      MOODLE=true
      LOAD_FILE="db/moodle_blank.sql"
      ;;
    b)
      LOAD=true
      MOODLE=true
      LOAD_FILE="db/moodle_db.sql"
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

DB_COUNT=`mysqlshow -u test -ptest --protocol=TCP --port=31337 | grep colab_dev | wc -l`
if [ $(($DB_COUNT)) = 0 ]; then
  echo "Initialise the DBs from the dev environment"
  exit
fi

# Load a sql file
if [ "$LOAD" = true ]; then
  if test -f "$LOAD_FILE"; then
    echo "Loading: $LOAD_FILE"
    if [ "$MOODLE" = false ]; then
        mysql colab_dev -u test -ptest --protocol=TCP --port=31337 < $LOAD_FILE
    else
        mysql moodle -u moodle -pmoodle --protocol=TCP --port=31337 < $LOAD_FILE
    fi
    echo "Loaded"
  else
    echo "File does not exist: $LOAD_FILE"
    echo "Exiting"
    exit
  fi
fi


