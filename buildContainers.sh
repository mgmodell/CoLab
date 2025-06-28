#!/bin/bash

echo -e '\t*****\n\tbuilding db'
podman build -f ./containers/agnostic/db/Dockerfile -t colab_db .
if [[ $? -eq 0 ]]; then
  podman tag colab_db colab_db:latest
  echo -e '\tbuild db: succeeded'
else
  echo -e '\n\t*****\n\tbuilding db failed\n\t*****\n'
  exit 1
fi

echo -e '\n\t*****\n\tbuilding app tester'
podman build -f ./containers/agnostic/tester_server/Dockerfile -t colab_tester .
if [[ $? -eq 0 ]]; then
  podman tag colab_tester colab_tester:latest
  echo -e '\tbuild tester: succeeded'
else
  echo -e '\tbuild tester: failed\n'
  exit 1
fi

echo -e '\n\t*****\n\tbuilding app dev'
podman build -f ./containers/agnostic/dev_server/Dockerfile -t colab_dev_server .
if [[ $? -eq 0 ]]; then
  podman tag colab_dev_server colab_dev_server:latest
  echo -e '\tbuild app dev: succeeded'
else
  echo -e '\tbuild app dev: failed\n'
  exit 1
fi
echo -e '\n\t*****\n\tbuilding browser'
podman build -f ./containers/agnostic/browser/Dockerfile -t colab_browser .
if [[ $? -eq 0 ]]; then
  podman tag colab_browser colab_browser:latest
  echo -e '\tbuild browser: succeeded'
else
  echo -e '\tbuild browser: failed\n'
  exit 1
fi
echo -e '\n\t*****\n\tbuilding moodle'
podman build -f ./containers/agnostic/moodle/Dockerfile -t colab_moodle .
if [[ $? -eq 0 ]]; then
  podman tag colab_moodle colab_moodle:latest
  echo -e '\tbuild moodle: succeeded'
else
  echo -e '\tbuild moodle: failed\n'
  exit 1
fi

