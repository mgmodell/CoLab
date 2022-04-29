#/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo 'building for arm'
  docker build containers/arm/db -t colab_db
  docker build containers/arm/app -t colab_app
  docker build containers/arm/browser -t colab_browser
else
  echo 'building for x86'
  docker build containers/x86/db -t colab_db
  docker build containers/x86/app -t colab_app
  docker build containers/x86/browser -t colab_browser
fi

