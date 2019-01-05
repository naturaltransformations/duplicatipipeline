#!/bin/bash
. /pipeline/docker-run/markers.sh
. /pipeline/shared/duplicati.sh

function upload_to_aws() {
	export AWS_ACCESS_KEY_ID=$awskeyid
	export AWS_SECRET_ACCESS_KEY=$awssecret
	aws s3 cp "${UPDATE_TARGET}/" "${awsbucket}/${releasetype}/" --recursive --exclude "docker.*"
}

function push_docker () {
	ARCHITECTURES="amd64 arm32v7"
	echo "$dockerpassword" | docker login -u="$dockeruser" --password-stdin

	for arch in $ARCHITECTURES; do
		docker load -i ${UPDATE_TARGET}/docker.linux-${arch}.tar
		loaded_tag=linux-${arch}-${releasetype}
   	tags="linux-${arch}-${releaseversion} linux-${arch}-${releasetype}"
		for tag in $tags; do
			docker tag ${dockerrepo}:${loaded_tag} ${dockerrepo}:${tag}
      docker push ${dockerrepo}:${tag}
		done
	done
}

travis_mark_begin "UPLOADING BINARIES"
push_docker
upload_to_aws
travis_mark_end "UPLOADING BINARIES"
