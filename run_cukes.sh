#!/bin/bash

# MOVE THIS PULL AND RISK STAGNATION
echo "Setting the current working directory"
. $HOME/.asdf/asdf.sh
cd $HOME/src/app
git pull
asdf reshim

print_help ( ) {
  echo "RunCukes: Script to launch automated tests"
  echo "Valid options:"
  echo " -s             Show the failures from previous run only"
  echo "                (Do not run any tests. Ignore -c or -n.)"
  echo " -b [branch]    Switch to [branch] and terminate"
  echo " -d [driver]    Set the browser driver for this run"
  echo " -c             Initialise the database"
  echo " -f [features]  Specify specific features to run"
  echo " -l             Clear out the log files"
  echo " -n             Wipe previous runs and terminate"
  echo " -r             Rerun previous failed tests with latest"
  echo "                code"
  echo " -t             Run a shell"
  echo " -h             Show this help and terminate"
  
  exit 0;

}

echo "Arguments: '$@'"

if [ "$#" -lt 1 ]; then
  echo "Please specify options"
  print_help
fi

DRIVER=docker
SHOW_FAILS=false
DB_RESET=false
CLEAR_LOG=false
CLEAR_RERUN=false
SHOW_HELP=false
SPEC_FEATURE=false

while getopts "chsnb:f:d:tl" opt; do
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
      git pull
      echo "Checked out branch $OPTARG" >&2
      exit 0;
      ;;
    f)
      echo "Features Specified $OPTARG" >&2
      SPEC_FEATURE=true
      FEATURE=$OPTARG
      ;;
    l)
      echo "Removing log files" >&2
      CLEAR_LOG=true
      ;;
    n)
      echo "Removing Rerun File" >&2
      CLEAR_RERUN=true
      ;;
    r)
      echo "Rerun recent failures" >&2
      # NOOP
      ;;
    t)
      /bin/bash -i
      exit 0;
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


# Show previous failures
if [ "$SHOW_FAILS" = true ]; then
  printf '%s\n' "$(cat rerun.txt)"
  exit 0;
fi

# Clear previous failures
if [ "$CLEAR_RERUN" = true ]; then
  > rerun.txt
  exit 0;
fi

# Clear old log files
if [ "$CLEAR_LOG" = true ]; then
  rm log/*
  exit 0;
fi

# Set up run context
RAILS_ENV=test
COLAB_DB=db
CUCUMBER_PUBLISH_TOKEN=caa67d94-0eab-4593-90c7-6032772d86ec
#RAILS_MASTER_KEY=4e2027b76f8638d77d05a617c748d877

echo "Installing platforms"
asdf plugin update --all
asdf install
echo "Installing gems"
bundle install --quiet
echo "Installing yarn packages"
yarn install --silent

# This doesn't seem to work properly
# rails webpacker:compile RAILS_ENV=$RAILS_ENV

if [ "$DB_RESET" = true ]; then
  # Reset database
  echo "Setting up database" >&2
  rails db:create RAILS_ENV=$RAILS_ENV COLAB_DB=db
  rails testing:db_init RAILS_ENV=$RAILS_ENV COLAB_DB=db
  echo "Database initialised "
elif [ "$SPEC_FEATURE" = true ]; then
  # Run the specialised tests
  echo "Begin the specified test executions: $FEATURE" >&2
  rails cucumber RAILS_ENV=$RAILS_ENV DRIVER=$DRIVER FEATURE=$FEATURE COLAB_DB=db
else
  # Run the tests
  echo "Begin the remaining test executions" >&2
  rails cucumber:rerun RAILS_ENV=$RAILS_ENV DRIVER=$DRIVER COLAB_DB=db
fi
