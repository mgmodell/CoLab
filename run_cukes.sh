#/bin/sh

git pull
bundle install
yarn install

# rails cucumber:rerun RAILS_ENV=docker CUCUMBER_PUBLISH_TOKEN=caa67d94-0eab-4593-90c7-6032772d86ec
