#!/bin/bash

# MOVE THIS PULL AND RISK STAGNATION
echo "Setting the current working directory"

print_help ( ) {
  echo "run_tests.sh: Script to launch containerized automated tests"
  echo "Valid options:"
  echo " -s             Show the failures from previous run only"
  echo "                (Do not run any tests.)"
  echo " -b [branch]    Switch to [branch] and terminate"
  echo " -c             Initialise the database and terminate"
  echo " -l             Clear out the log files"
  echo " -n             Wipe previous runs"
  echo " -o		Show output (if running)"
  echo " -x		Shut down support processes and terminate"
  echo "       Run-specific options:"
  echo " -d [driver]    Set the browser driver for this run"
  echo " -f [features]  Specify specific features to run"
  echo " -r             Rerun previous failed tests with latest"
  echo "                code (recommended)"
  echo " -t             Run a shell"
  echo " -e             Exit before running tests"
  echo " -h             Show this help and terminate"

  exit 0;

}

if [ "$#" -lt 1 ]; then
  echo "Please specify options"
  print_help
fi

SHOW_FAILS=false
RUN_TERM=false
DROP_SUPPORT=false
while getopts "soxb:clndfrteh" opt; do
  case $opt in
    x) # Open up a terminal
      DROP_SUPPORT=true
      ;;
    s) # Show failures
      SHOW_FAILS=true
      ;;
    t) # Open up a terminal
      RUN_TERM=true
      ;;
    o)
      OUTPUT_HASH=`docker ps | grep colab_tester | awk '{print $1;}'`
      docker logs -f $OUTPUT_HASH
      exit 0;
      ;;
    h|\?) #Invalid option
      print_help
      exit 0;
      ;;
  esac
done

pushd containers/test_env/
if [ "$RUN_TERM" = true ]; then
  docker compose run --rm --entrypoint='' app /bin/bash

elif [ "$SHOW_FAILS" = true ]; then
  echo "Show previous run failures"
  docker compose run --rm --entrypoint='' app /bin/cat /home/colab/src/app/rerun.txt
  echo -e "\nEnd failure listing\n"

elif [ "$DROP_SUPPORT" = true ]; then
  docker compose down 

else
  docker compose run --rm -d app $@
fi
popd
