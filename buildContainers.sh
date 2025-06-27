#!/bin/bash

echo -e '\n\t*****\n\tbuilding db'
podman build -f ./containers/agnostic/db/Dockerfile -t colab_db .
echo -e '\n\t*****\n\tbuilding app tester'
podman build -f ./containers/agnostic/tester_server/Dockerfile -t colab_tester .
echo -e '\n\t*****\n\tbuilding app dev'
podman build -f ./containers/agnostic/dev_server/Dockerfile -t colab_dev_server .
echo -e '\n\t*****\n\tbuilding browser'
podman build -f ./containers/agnostic/browser/Dockerfile -t colab_browser .
echo -e '\n\t*****\n\tbuilding moodle'
podman build -f ./containers/agnostic/moodle/Dockerfile -t colab_moodle .

