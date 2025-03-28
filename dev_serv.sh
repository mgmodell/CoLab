#!/bin/bash

print_help ( ) {
  echo "dev_serv: Script to interact with dev server in containerized"
  echo "          environment"
  echo "Valid options:"
  echo " -s             Start the server (cannot be combined)"
  echo " -f [features]  Specify specific features to run"
  echo ""
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

if [ -f /.dockerenv ]; then
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
RUN_TASK_M=false
RUN_TASK_E=false
RUN_TASK_A=false
FEATURE=false
LOAD=false
STARTUP=false

# Set up a variable for the container
export HOSTNAME=$(hostname -s)

while getopts "a:cf:q:dtsm:e:h" opt; do
  case $opt in
    q)
      if [[ $OPTARG == "moodle" ]]; then
        mysql moodle -u moodle -pmoodle --protocol=TCP --port=31337
      else
        mysql colab_dev -u test -ptest --protocol=TCP --port=31337
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
  esac
done

# Handle Command Help Request
if [ "$SHOW_HELP" = true ]; then
  print_help
fi

rails db:prepare


# Migrate the DB
if [ "$MIGRATE" = true ]; then
  echo "Migrating the DB..."
  rails db:migrate COLAB_DB=db COLAB_DB_PORT=3306
fi

# Run a migratify task
if [ "$RUN_TASK_M" = true ]; then
  echo 'Migratify Task'
  rails migratify:$RUN_TASK_M_NAME COLAB_DB=db COLAB_DB_PORT=3306
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

# Start the server
if [ "$STARTUP" = true ]; then
  foreman start -f Procfile.dev
fi


