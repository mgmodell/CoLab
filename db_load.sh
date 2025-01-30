#!/bin/bash

print_help ( ) {
  echo "db_load: Script to load dev db"
  echo "Valid options:"
  echo " -l [sql dump]  Load DB from dump"
  echo " -j             Load latest dev db dump"
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
pushd containers/dev_env

# Set up run context
COLAB_DB=db
COLAB_DB_PORT=3306

SHOW_HELP=false
MIGRATE=false
LOAD=false
COUNT_OPTS=0

# Set up a variable for the container
export HOSTNAME=$(hostname -s)

while getopts "jl:h" opt; do
  COUNT_OPTS=$(($COUNT_OPTS + 1))
  case $opt in
    l)
      LOAD=true
      LOAD_FILE="../../$OPTARG"
      ;;
    j)
      LOAD=true
      LOAD_FILE="../../db/dev_db.sql"
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
    echo "Loading"
    mysql colab_dev -u test -ptest --protocol=TCP --port=31337 < $LOAD_FILE
    echo "Loaded"
  else
    echo "File does not exist: $LOAD_FILE"
    ls ../../
    echo "Exiting"
    popd
    exit
  fi
fi

popd

