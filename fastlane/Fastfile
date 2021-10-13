# This file contains the fastlane.tools configuration
# You can find the documentation at https://docs.fastlane.tools
#
# For a list of all available actions, check out
#
#     https://docs.fastlane.tools/actions
#
# For a list of all available plugins, check out
#
#     https://docs.fastlane.tools/plugins/available-plugins
#

# Uncomment the line if you want fastlane to automatically update itself
# update_fastlane

default_platform(:android)

platform :android do
  desc "Deploy App to internal"
  lane :deploy do
    track = ENV["TRACK"]
    package_name = ENV["PACKAGE_NAME"]


    properties = {
      "dev.is_deploying" => "true",
      "android.injected.signing.store.file" => ENV["KEYSTORE_FILE"],
      "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
      "android.injected.signing.key.alias" => ENV["KEY_ALIAS"],
      "android.injected.signing.key.password" => ENV["KEY_PASSWORD"]
    }

   #gi = google_play_track_version_codes package_name:package_name, track:track
   #version_updated = gi + 1
   increment_version_code(gradle_file_path: "./app/build.gradle", version_code: 12)

    gradle(
      task: "bundle",
      build_type: "Release",
      properties: properties,
      print_command: false
    )
    upload_to_play_store(
        skip_upload_screenshots: true,
        skip_upload_images: true,
        skip_upload_apk: true,
        skip_upload_metadata: true,
        package_name: package_name,
        track: track,
        aab: Actions.lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH],
    )
  end
end
