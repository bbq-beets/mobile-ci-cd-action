#!/bin/sh -l

echo "Hello"
FASTFILE=fastlane/AppFile
if [[ -f "$FASTFILE" ]]; then
    echo "fastlane file exists."
else
    echo "fastlane file does not exist."
fi
