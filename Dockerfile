FROM alpine:3.10
COPY entrypoint.sh /entrypoint.sh
COPY fastlane /fastlane/
ENTRYPOINT ["/entrypoint.sh"]
