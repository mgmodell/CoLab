#!/bin/bash

print_help ( ) {
  echo "StartDev: Script to launch containerized dev server"
  echo "Valid options:"
  echo " -s             Start the server (cannot be combined)"
  echo " -x             Stop the server (cannot be combined)"
  echo ""
  echo " -l [sql dump]  Load DB from dump (assumes -m)"
  echo " -j             Load latest dev db dump (assumes -m)"
  echo " -d             Migrate the DB"
  echo " -c             Run the rails console (then terminate)"
  echo " -o             Monitor the running server"
  echo " -t             Open up a terminal on the dev server"
  echo " -q             Open mysql terminal"
  echo " -m [task]      Run a migratify task (assumes -m)"
  echo " -e [task]      Run a tEsting task (then terminate)"
  echo ""
  echo " -h             Show this help and terminate"
  
  exit 0;

}

show_output( ) {
  OUTPUT_HASH=`docker ps | grep dev_env_app | awk '{print $1;}'`
  docker logs -f $OUTPUT_HASH
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

DRIVER=docker
SHOW_HELP=false
MIGRATE=false
RUN_TASK_M=false
RUN_TASK_E=false
LOAD=false
WATCH=false
STARTUP=false

if lsof -Pi :31337 -sTCP:LISTEN -t >/dev/null; then
  echo "DB Running"
else
  echo "DB needs to be started"
  docker compose up -d db
  sleep 2
  echo "DB started"
fi


while getopts "cqtosjxm:l:e:h" opt; do
  case $opt in
    q)
      mysql colab_dev -u test -ptest --protocol=TCP --port=31337
      popd
      exit
      ;;
    c)
      docker compose run --rm app "rails console"
      popd
      exit
      ;;
    t)
      docker compose run --rm app /bin/bash
      popd
      exit
      ;;
    s)
      STARTUP=true
      ;;
    x)
      OUTPUT_HASH=`docker ps | grep dev_env | awk '{print $1;}'`
      docker kill $OUTPUT_HASH
      popd
      if [ -f tmp/pids/server.pid ] ; then
      	rm tmp/pids/server.pid
      fi
      exit
      ;;
    l)
      MIGRATE=true
      LOAD=true
      LOAD_FILE="../../$OPTARG"
      ;;
    j)
      MIGRATE=true
      LOAD=true
      LOAD_FILE="../../db/dev_db.sql"
      ;;
    o)
      WATCH=true
      ;;
    e)
      RUN_TASK_E=true
      RUN_TASK_E_NAME=$OPTARG
      MIGRATE=true
      ;;
    m)
      RUN_TASK_M=true
      RUN_TASK_M_NAME=$OPTARG
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

DB_COUNT=`mysqlshow -u test -ptest --protocol=TCP --port=31337 | grep colab_dev | wc -l`
if [ $(($DB_COUNT)) = 0 ]; then
  echo "Creating the DB"
  docker compose run --rm app "rails db:create COLAB_DB=db COLAB_DB_PORT=3306"
  echo "Created the DB"
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
  echo 'Migrating'
  docker compose run --rm app "rails db:migrate COLAB_DB=db COLAB_DB_PORT=3306"
fi

# Run a migratify task
if [ "$RUN_TASK_M" = true ]; then
  echo 'Migratify Task'
  docker compose run --rm app "rails migratify:$RUN_TASK_M_NAME COLAB_DB=db COLAB_DB_PORT=3306"
fi

# Run a testing task
if [ "$RUN_TASK_E" = true ]; then
  echo 'Testing Task'
  docker compose run --rm app "rails testing:$RUN_TASK_E_NAME COLAB_DB=db COLAB_DB_PORT=3306"
fi

# Start the server
if [ "$STARTUP" = true ]; then
  docker compose run -d --rm --service-ports app "foreman start -f Procfile.dev"
fi

if [ "$WATCH" = true ]; then
  show_output
fi

popd

