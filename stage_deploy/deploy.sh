#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

function append_json_installers () {
cat >> "${UPDATE_TARGET}/latest-installers.json" <<EOF
	"$2": {
		"name": "$1",
		"url": "https://updates.duplicati.com/${BUILDTYPE}/$1",
		"md5": "${MD5}",
		"sha1": "${SHA1}",
		"sha256": "${SHA256}"
	},
EOF
}

function close_json_installers () {
cat >> "${UPDATE_TARGET}/latest-installers.json" <<EOF
	"version": "${RELEASE_VERSION}"
}
EOF
}

function write_json_latest () {
cat > "${UPDATE_TARGET}/latest.json" <<EOF
{
	"version": "${RELEASE_VERSION}",
	"zip": "${RELEASE_FILE_NAME}.zip",
	"zipsig": "${RELEASE_FILE_NAME}.zip.sig",
	"zipsigasc": "${RELEASE_FILE_NAME}.zip.sig.asc",
	"manifest": "${RELEASE_FILE_NAME}.manifest",
	"urlbase": "https://updates.duplicati.com/${RELEASE_TYPE}/",
	"link": "https://updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip",
	"zipmd5": "${MD5}",
	"zipsha1": "${SHA1}",
	"zipsha256": "${SHA256}"
}
EOF
}

#aws s3 cp "${ZIP_FILE_WITH_SIGNATURES}" "${AWS_BUCKET_URI}/${RELEASE_TYPE}/${ZIP_FILE_WITH_SIGNATURES}"
#aws s3 cp "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip.sig" "${AWS_BUCKET_URI}/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip.sig"
#aws s3 cp "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip.sig.asc" "${AWS_BUCKET_URI}/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip.sig.asc"
#aws s3 cp "${AWS_BUCKET_URI}/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.manifest" "${AWS_BUCKET_URI}/${RELEASE_TYPE}/latest.manifest"
function upload_to_aws() {
	echo "{" > "${UPDATE_TARGET}/latest-installers.json"

    for file in $(ls ${UPDATE_TARGET}/*.{zip,spk,rpm,deb}); do
	    filename=$(basename "${file}")
		local MD5=$(md5sum ${UPDATE_TARGET}/$filename | awk -F ' ' '{print $NF}')
	    local SHA1=$(shasum -a 1 ${UPDATE_TARGET}/$filename | awk -F ' ' '{print $1}')
    	local SHA256=$(shasum -a 256 ${UPDATE_TARGET}/$filename | awk -F ' ' '{print $1}')

    	append_json_installers
    	if [ "${filename##*.}" == "zip" ]; then
			write_json_latest
	    fi
    done

    close_json_installers

	echo "duplicati_installers =" > "${UPDATE_TARGET}/latest-installers.js"
	cat "${UPDATE_TARGET}/latest-installers.json" >> "${UPDATE_TARGET}/latest-installers.js"
	echo ";" >> "${UPDATE_TARGET}/latest-installers.js"

	echo "duplicati_version_info =" > "${UPDATE_TARGET}/latest.js"
	cat "${UPDATE_TARGET}/latest.json" >> "${UPDATE_TARGET}/latest.js"
	echo ";" >> "${UPDATE_TARGET}/latest.js"

	export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
	export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
    aws s3 cp "${UPDATE_TARGET}/" "${AWS_BUCKET_URI}/${RELEASE_TYPE}/" --recursive
}

parse_options "$@"
travis_mark_begin "UPLOADING BINARIES"
upload_to_aws
travis_mark_end "UPLOADING BINARIES"

