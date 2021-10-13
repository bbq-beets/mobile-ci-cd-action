#!/bin/sh -l

PACKAGE_NAME=$1
KEY_STORE=$2
PLAY_STORE_CREDS=$3
PUSH_CHANGES=$4
GIT_USER_NAME=$5
GIT_USER_EMAIL=$6

PROJECT_ROOT=$GITHUB_WORKSPACE
FASTLANEDIR=$PROJECT_ROOT/fastlane
JSON_KEY_FILE=/play-store-credentials.json

cd $PROJECT_ROOT

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
    else
        echo "Gemfile already exists and already references fastlane; not taking any action"
    fi
fi

if [[ ! -d "$FASTLANEDIR" ]]; then
    echo "Creating $FASTLANEDIR dir"
    mkdir $FASTLANEDIR
else
    echo "$FASTLANEDIR directory already exists"
fi

if [[ ! -f "Appfile" ]]; then
    echo "Creating Appfile"
    touch $FASTLANEDIR/Appfile
    echo '$PLAY_STORE_CREDS' > $JSON_KEY_FILE
    echo 'json_key_file("'$JSON_KEY_FILE'")' >> $FASTLANEDIR/Appfile
    echo 'package_name("'$PACKAGE_NAME'")' >> $FASTLANEDIR/Appfile
else
    echo "Appfile already exists; not taking any action"
fi

# TODO Fastfile. This one might be quite big with only little pieces replaced by variable inputs,
# so we should find a nice way of coding that

echo "Running Bundler"
bundle install

# Run fastlane

# Commit and push specific changes
if [[ $PUSH_CHANGES ]]; then
    git config --global user.name $GIT_USER_NAME
    git config --global user.email $GIT_USER_EMAIL
    # TODO do we care which branch we're on?
    # TODO do we want to commit Gemfile.lock?
    git add $PROJECT_ROOT/Gemfile
    git add $FASTLANEDIR/Appfile
    git add $FASTLANEDIR/Fastfile
    git commit -m "Configure fastlane"
    # TODO We probably don't have the right to push...
fi
