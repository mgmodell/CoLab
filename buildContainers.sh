#!/bin/bash

# This script builds the containers for the Colab project using Podman.
print_help ( ) {
    echo "buildContainers: Script to build Colab containers using Podman"
    echo "Valid options:"
    echo " -n             Build containers without relying upon the cached layers"
    echo " -d             Build dev containers only"
    echo " -t             Build test containers only"
    echo " -h             Show this help and terminate"
    exit 0;
}

# Function to test the result of the build command
# Arguments:
#   $1 - Exit status of the build command
#   $2 - Name of the container being built
# If the build is successful, it tags the container with 'latest' and prints a success
# message. If it fails, it prints an error message and exits with status 1.
test_result ( ) {
    if [[ $1 -eq 0 ]]; then
      podman tag $2 $2:latest
      echo -e "\tbuild $2: succeeded"
    else
      echo -e "\n\t*****\n\tbuilding $2 failed\n\t*****\n"
      exit 1
    fi

}

BUILD_OPTS=""
DEV_ONLY=false
TEST_ONLY=false
while getopts "nhdt" opt; do
  case $opt in
    n)
      echo "Building containers without cache"
      BUILD_OPTS="--no-cache"
      ;;
    h)
      print_help
      ;;
    d)
      DEV_ONLY=true
      ;;
    t)
      TEST_ONLY=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      print_help
      ;;
  esac
done

echo -e '\t*****\n\tbuilding db'
podman build $BUILD_OPTS -f ./containers/agnostic/db/Dockerfile -t colab_db .
test_result $? 'colab_db'

if [ "$DEV_ONLY" != true ]; then
    echo -e '\n\t*****\n\tbuilding app tester'
    podman build $BUILD_OPTS -f ./containers/agnostic/tester_server/Dockerfile -t colab_tester .
    test_result $? 'colab_tester'
fi

if [ "$TEST_ONLY" != true ]; then
    echo -e '\n\t*****\n\tbuilding app dev'
    podman build $BUILD_OPTS -f ./containers/agnostic/dev_server/Dockerfile -t colab_dev_server .
    test_result $? 'colab_dev_server'

    echo -e '\n\t*****\n\tbuilding browser'
    podman build $BUILD_OPTS -f ./containers/agnostic/browser/Dockerfile -t colab_browser .
    test_result $? 'colab_browser'

    echo -e '\n\t*****\n\tbuilding moodle'
    podman build $BUILD_OPTS -f ./containers/agnostic/moodle/Dockerfile -t colab_moodle .
    test_result $? 'colab_moodle'
fi
