#!/bin/sh -l

PACKAGE_NAME=$1
KEY_STORE=$2
PLAY_STORE_CREDS=$3

FASTLANEDIR=fastlane
JSON_KEY_FILE=$FASTLANEDIR/play-store-credentials.json

echo "Updating apk"
apk update

echo "Installing packages"
apk add ruby-dev
apk add ruby-full
apk add build-base
apk add git

echo "Installing Bundler"
gem install --no-ri --no-rdoc bundler

if [[ ! -f "Gemfile" ]]; then
    echo "Copying Gemfile"
    cp /fastlane/Gemfile Gemfile
else
    # Add fastlane to the exising gemfile if it isn't referenced (including as a dependency)
    if ! bundle list | grep 'fastlane'; then
        bundle add fastlane
    fi
fi

if [[ ! -d "$FASTLANEDIR" ]]; then
    echo "Creating $FASTLANEDIR dir"
    mkdir $FASTLANEDIR
fi

cd $FASTLANEDIR
echo "In $FASTLANEDIR"

echo $PLAY_STORE_CREDS > /play-store-credentials.json

if [[ ! -f "Appfile" ]]; then
    echo "Creating Appfile"
    touch Appfile
    echo json_key_file("/play-store-credentials.json") >> Appfile
    echo package_name("$PACKAGE_NAME") >> Appfile
fi

# TODO Fastfile. This one might be quite big with only little pieces replaced by variable inputs,
# so we should find a nice way of coding that

echo "Running Bundler"
bundle install

# Run fastlane

# Commit and push specific changes
cd $GITHUB_WORKSPACE
# TODO git config --global user.name
# TODO git config --global user.email
# TODO do we care which branch we're on?
# TODO do we want to commit Gemfile.lock?
git add ./$FASTLANEDIR/Appfile
git add ./$FASTLANEDIR/Fastfile
git commit -m "Configure fastlane"
# TODO We probably don't have the right to push...
