#!/bin/sh -l

echo "Updating apt"
apk update

echo "Installing tools"
apk add ruby-dev
apk add ruby-etc
apk add build-base

echo "Installing Bundler"
gem install bundler

# TODO create Gemfile

echo "Running Bundler"
bundle install

FASTFILE=fastlane/AppFile
if [[ -f "$FASTFILE" ]]; then
    echo "fastlane file exists."
else
    echo "fastlane file does not exist."
fi
