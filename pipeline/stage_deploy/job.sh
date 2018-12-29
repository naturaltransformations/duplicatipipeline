#!/bin/bash
. /pipeline/shared/duplicati.sh
. /pipeline/shared/markers.sh

function upload_to_aws() {
	export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
	export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
	aws s3 cp "${UPDATE_TARGET}/" "${AWS_BUCKET_URI}/${RELEASE_TYPE}/" --recursive --exclude "docker.*"
}

function push_docker () {
	ARCHITECTURES="amd64 arm32v7"
	echo "$DOCKER_PASSWORD" | docker login -u="$DOCKER_USER" --password-stdin

	for arch in $ARCHITECTURES; do
		docker load -i ${UPDATE_TARGET}/docker.linux-${arch}.tar
		loaded_tag=linux-${arch}-${RELEASE_TYPE}
   	tags="linux-${arch}-${RELEASE_VERSION} linux-${arch}-${RELEASE_TYPE}"
		for tag in $tags; do
			docker tag ${DOCKER_REPO}:${loaded_tag} ${DOCKER_REPO}:${tag}
      docker push ${DOCKER_REPO}:${tag}
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
      * )
        break
        ;;
      esac
      if [[ $2 =~ ^--.* || -z $2 ]]; then
        shift
      else
        shift
        shift
      fi
  done
}

parse_duplicati_options "$@"
parse_module_options "${FORWARD_OPTS[@]}"

travis_mark_begin "UPLOADING BINARIES"
push_docker
upload_to_aws
travis_mark_end "UPLOADING BINARIES"
