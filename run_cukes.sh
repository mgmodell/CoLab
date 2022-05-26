#!/bin/bash

print_help( ){
  echo "RunCukes: Script to launch automated tests"
  echo "Valid options:"
  echo " -s             Show the failures from previous run only"
  echo "                (Do not run any tests. Ignore -c or -n.)"
  echo " -b [branch]    Switch to [branch]"
  echo " -d [driver]    Set the browser driver for this run"
  echo " -c             Initialise the database"
  echo " -f [features]  Specify specific features to run"
  echo " -n             Wipe previous runs"
  echo " -r             Rerun previous failed tests with latest"
  echo "                code"
  echo " -h             Show this help and terminate"
  
  exit 0;;

}

if [ "$#" -lt 1 ]; then
  echo "Please specify options"
  print_help
fi

DRIVER=docker
SHOW_FAILS=false
DB_RESET=false
CLEAR_RERUN=false
SHOW_HELP=false

while getopts "chsnb:f:d:" opt; do
  case $opt in
    c)
      DB_RESET=true
      ;;
    d)
      echo "Setting driver to $OPTARG" >&2
      DRIVER=$OPTARG
      ;;
    s)
      echo "Showing Rerun File" >&2
      SHOW_FAILS=true
      ;;
    b)
      echo "Checking out branch $OPTARG" >&2
      git checkout $OPTARG
      ;;
    f)
      echo "Features Specified $OPTARG" >&2
      FEATURE=$OPTARG
      ;;
    n)
      echo "Removing Rerun File" >&2
      CLEAR_RERUN=true
      ;;
    r)
      echo "Rerun recent failures" >&2
      # NOOP
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

echo "Setting the current working directory"
. $HOME/.asdf/asdf.sh
cd $HOME/src/app

# Show previous failures
if [ "$SHOW_FAILS" = true ]; then
  cat rerun.txt
  exit 0;
fi

# Clear previous failures
if [ "$CLEAR_RERUN" = true ]; then
  rm rerun.txt
fi

# Set up run context
git pull
asdf reshim

RAILS_ENV=docker
CUCUMBER_PUBLISH_TOKEN=caa67d94-0eab-4593-90c7-6032772d86ec
#RAILS_MASTER_KEY=4e2027b76f8638d77d05a617c748d877

asdf install
bundle install
yarn install

if [ "$DB_RESET" = true ]; then
  # Reset database
  echo "Setting up database" >&2
  rails db:create RAILS_ENV=$RAILS_ENV
else
  # Run the tests
  echo "Begin the test execution" >&2
  rails cucumber:rerun RAILS_ENV=$RAILS_ENV
fi

