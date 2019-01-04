#!/bin/bash
. /pipeline/shared/duplicati.sh
. /pipeline/shared/markers.sh

function upload_to_aws() {
	export AWS_ACCESS_KEY_ID=$awskeyid
	export AWS_SECRET_ACCESS_KEY=$awssecret
	aws s3 cp "${UPDATE_TARGET}/" "${awsbucket}/${RELEASE_TYPE}/" --recursive --exclude "docker.*"
}

function push_docker () {
	ARCHITECTURES="amd64 arm32v7"
	echo "$dockerpassword" | docker login -u="$dockeruser" --password-stdin

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

parse_duplicati_options "$@"
get_value awskeyid
get_value awssecret
get_value awsbucket
get_value dockeruser
get_value dockerpassword

travis_mark_begin "UPLOADING BINARIES"
push_docker
upload_to_aws
travis_mark_end "UPLOADING BINARIES"
