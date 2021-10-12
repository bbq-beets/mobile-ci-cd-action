#!/bin/sh -l

echo "Updating apt"
apt update

echo "Installing Ruby"
apt install ruby-full -y

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
