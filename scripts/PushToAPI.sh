sha256() {
  sha256sum $1 | awk '{print $1}'
}

prop() {
  grep "${1}" gradle.properties | cut -d'=' -f2 | sed 's/\r//'
}

project_id="luminol"
mcversion_group=$(prop GroupMCV)
mcversion=$(prop mcVersion)
pre=$(prop preVersion)

if [ $pre = "true" ]; then
  channel="experimental"
else
  channel="default"
fi
changes=$(git log -1 --pretty="[{\\\"commit\\\": \\\"%H\\\", \\\"message\\\": \\\"%s\\\", \\\"summary\\\": \\\"%b\\\"}]")
jar_sha256=`sha256 build/libs/luminol-1.20.4-paperclip.jar`
jar_name="luminol-1.20.4-paperclip.jar"
ctime=$(date -u +"%s")"000"

# v2
echo "Authentication: $secret_v2"
#echo "{\"version_group\":\"$mcversion_group\",\"channel\":\"$channel\",\"changes\":\"$changes\",\"jar_name\":\"$jar_name\",\"sha256\":\"$jar_sha256\",\"release_tag\":\"$tag\",\"time\":\"$ctime\"}" > data.json
json=$(printf "{\\\"channel\\\":\\\"%s\\\", \\\"jar_name\\\":\\\"%s\\\", \\\"sha256\\\":\\\"%s\\\", \\\"tag\\\":\\\"%s\\\", \\\"time\\\":\\\"%s\\\", \\\"changes\\\":\\\"%s\\\"}" \
    "$channel" "$jar_name" "$jar_sha256" "$tag" "$ctime" "$changes")
echo "[DEBUG] $json"
echo "[DEBUG] curl --location --request POST \"https://api.luminolmc.com/v2/projects/$project_id/$mcversion/build/commit\" \
    -H \"Content-Type: application/json\" \
    -H \"Authorization: $secret_v2\" \
    -d \"$json\""
response=$(curl --location --request POST "https://api.luminolmc.com/v2/projects/$project_id/$mcversion/build/commit" \
    -H "Content-Type: application/json" \
    -H "Authorization: $secret_v2" \
    -d "$json")
echo "[RESPONSE] $response"
