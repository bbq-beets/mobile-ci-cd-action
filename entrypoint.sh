#!/bin/sh -l

PACKAGE_NAME=$1
TRACK=$2
KEYSTORE_ENCODED=$3
PLAY_STORE_CREDS=$4
KEYSTORE_PASSWORD=$5
KEY_ALIAS=$6
KEY_PASSWORD=$7
PUSH_CHANGES=$8
GIT_USER_NAME=$9
GIT_USER_EMAIL=$10

PROJECT_ROOT=$GITHUB_WORKSPACE
FASTLANEDIR=$PROJECT_ROOT/fastlane
SECRETS_DIR=/secrets
JSON_KEY_FILE=$SECRETS_DIR/play-store-credentials.json
KEYSTORE_FILE=$SECRETS_DIR/keystore.jks

cd $PROJECT_ROOT

mkdir $SECRETS_DIR

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
    echo "$PLAY_STORE_CREDS" > $JSON_KEY_FILE
    echo 'json_key_file("'$JSON_KEY_FILE'")' >> $FASTLANEDIR/Appfile
    echo 'package_name("'$PACKAGE_NAME'")' >> $FASTLANEDIR/Appfile
else
    echo "Appfile already exists; not taking any action"
fi

if [[ ! -f "Fastfile" ]]; then
    echo "Copying Fastfile"
    cp /fastlane/Fastfile $FASTLANEDIR/Fastfile
else
    echo "Fastfile already exists; not taking any action"
fi

if [[ ! -f "Pluginfile" ]]; then
    echo "Copying Pluginfile"
    cp /fastlane/Pluginfile $FASTLANEDIR/Pluginfile
else
    echo "Pluginfile already exists; TODO add the plugin we need if it isn't in there"
fi

echo "Running Bundler"
bundle install

echo "$KEYSTORE_ENCODED" | base64 --decode > $KEYSTORE_FILE

# Run fastlane
bundle exec fastlane update_plugins
bundle exec fastlane android deploy

# TODO always clean up, also in case of failure
rm -r $SECRETS_DIR

# Commit and push specific changes
if [[ $PUSH_CHANGES ]]; then
    git config --global user.name $GIT_USER_NAME
    git config --global user.email $GIT_USER_EMAIL
    # TODO do we care which branch we're on?
    # TODO do we want to commit Gemfile.lock?
    git add $PROJECT_ROOT/Gemfile
    git add $FASTLANEDIR/Appfile
    git add $FASTLANEDIR/Fastfile
    git add $FASTLANEDIR/Pluginfile
    git commit -m "Configure fastlane"
    # TODO We probably don't have the right to push...
fi
