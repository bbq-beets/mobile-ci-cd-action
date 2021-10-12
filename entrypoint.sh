#!/bin/sh -l

KEY_STORE=$1
PLAY_STORE_CREDS=$2

FASTLANEDIR=fastlane
JSON_KEY_FILE=$FASTLANEDIR/play-store-credentials.json

echo "Updating apt"
apk update

echo "Installing packages"
apk add ruby-dev
apk add ruby-full
apk add build-base

echo "Installing Bundler"
gem install  --no-ri --no-rdoc bundler

if [[ ! -d "$FASTLANEDIR" ]]; then
    echo "Creating $FASTLANEDIR dir"
    mkdir $FASTLANEDIR
fi

cd $FASTLANEDIR
echo "In $FASTLANEDIR"

if [[ ! -f "Gemfile" ]]; then
    echo "Copying Gemfile"
    cp /fastlane/Gemfile Gemfile
fi

echo $PLAY_STORE_CREDS > /play-store-credentials.json

if [[ ! -f "Appfile" ]]; then
    echo "Creating Appfile"
    touch Appfile
    echo json_key_file("/play-store-credentials.json") >> Appfile
    echo package_name("com.octogame") >> Appfile # TODO
fi

# TODO Fastfile. This one might be quite big with only little pieces replaced by variable inputs,
# so we should find a nice way of coding that

echo "Running Bundler"
bundle install

# TODO Run fastlane

tail -f /dev/null
