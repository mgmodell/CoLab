#!/bin/bash

print_help ( ) {
  echo "StartDev: Script to launch containerized dev server"
  echo "Valid options:"
  echo " -s             Start the server (cannot be combined)"
  echo " -x             Stop the server (cannot be combined)"
  echo ""
  echo " -l [sql dump]  Load DB from dump (assumes -m)"
  echo " -d             Migrate the DB"
  echo " -o             Monitor the running server"
  echo " -t             Open up a terminal on the dev server"
  echo " -m [task]      Run a migratify task (assumes -m)"
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

DRIVER=docker
SHOW_HELP=false
MIGRATE=false
RUN_TASK=false
LOAD=false
WATCH=false
STARTUP=false

if lsof -Pi :31337 -sTCP:LISTEN -t >/dev/null; then
  echo "DB Running"
else
  echo "DB needs to be started"
  docker-compose up -d db
  sleep 2
  echo "DB started"
fi

DB_COUNT=`mysqlshow -u test -ptest --protocol=TCP --port=31337 | grep colab_dev | wc -l`
if [ $(($DB_COUNT)) = 0 ]; then
  echo "Creating the DB"
  docker-compose run --rm app "rails db:create COLAB_DB=db COLAB_DB_PORT=3306"
  echo "Created the DB"
fi

while getopts "tosxm:l:h" opt; do
  case $opt in
    t)
      docker-compose run --rm app /bin/bash
      popd
      exit
      ;;
    s)
      STARTUP=true
      ;;
    x)
      OUTPUT_HASH=`docker ps | grep dev_env_app | awk '{print $1;}'`
      docker kill $OUTPUT_HASH
      popd
      rm tmp/pids/server.pid
      exit
      ;;
    l)
      MIGRATE=true
      LOAD=true
      LOAD_FILE="../../$OPTARG"
      ;;
    o)
      WATCH=true
      ;;
    m)
      RUN_TASK=true
      RUN_TASK_NAME=$OPTARG
      MIGRATE=true
      ;;
    d)
      MIGRATE=true
      ;;
    h|\?) #Invalid option
      SHOW_HELP=true
      ;;
  esac
done

# Handle Command Help Request
if [ "$SHOW_HELP" = true ]; then
  print_help
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

# Migrate the DB
if [ "$MIGRATE" = true ]; then
  docker-compose run --rm app "rails db:migrate COLAB_DB=db COLAB_DB_PORT=3306"
fi

# Run a migratify task
if [ "$RUN_TASK" = true ]; then
  docker-compose run --rm app "rails migratify:$RUN_TASK_NAME COLAB_DB=db COLAB_DB_PORT=3306"
fi

# Start the server
if [ "$STARTUP" = true ]; then
  docker-compose run -d --rm --service-ports app "foreman start -f Procfile.dev"
fi

if [ "$WATCH" = true ]; then
  OUTPUT_HASH=`docker ps | grep dev_env_app | awk '{print $1;}'`
  docker logs -f $OUTPUT_HASH
fi

popd

