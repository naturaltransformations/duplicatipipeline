#!/bin/bash
. /pipeline/shared/duplicati.sh
. /pipeline/shared/markers.sh

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
    aws s3 cp "${UPDATE_TARGET}/" "${AWS_BUCKET_URI}/${RELEASE_TYPE}/" --recursive --exclude "docker.*"
}

function push_docker () {
	ARCHITECTURES="amd64 arm32v7"
	echo "$DOCKER_PASSWORD" | docker login -u="$DOCKER_USER" --password-stdin

	for arch in $ARCHITECTURES; do
		docker load -i ${UPDATE_TARGET}/docker.linux-${arch}-${RELEASE_TYPE}.tar
    	tags="linux-${arch}-${RELEASE_VERSION} linux-${arch}-${RELEASE_TYPE}"
		for tag in $tags; do
	        docker push ${DOCKER_REPOSITORY}:${tag}
		done
	done

}

function parse_module_options () {
  while true ; do
      case "$1" in
      --awskeyid)
        AWS_ACCESS_KEY_ID="$2"
        ;;
      --awssecret)
        AWS_SECRET_ACCESS_KEY="$2"
        ;;
      --awsbucket)
        AWS_BUCKET_URI="$2"
        ;;
  	  --dockeruser)
		DOCKER_USER="$2"
		;;
      --dockerpassword)
        DOCKER_PASSWORD="$2"
        ;;
      "" )
        break
        ;;
      esac
      FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
      FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$2"
      shift
      shift
  done
}

parse_module_options "$@"
parse_duplicati_options "${FORWARD_OPTS[@]}"

travis_mark_begin "UPLOADING BINARIES"
push_docker
upload_to_aws
travis_mark_end "UPLOADING BINARIES"
