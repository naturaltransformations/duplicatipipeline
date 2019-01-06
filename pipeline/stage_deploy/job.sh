#!/bin/bash
. /pipeline/docker-run/markers.sh
. /pipeline/shared/duplicati.sh

function aws_clean_up() {
  aws s3 ls "$awsbucket/" --recursive | while read -r line;
    do
      createDate=`echo $line|awk {'print $1" "$2'}`
      createDate=`date -d"$createDate" +%s`
      olderThan=`date --date "3 days ago" +%s`
      if [[ $createDate -lt $olderThan ]]; then
        fileName=`echo $line|awk {'print $4'}`
        if [[ $fileName != "" ]]; then
          aws s3 rm "${awsbucket}"/$fileName
        fi
      fi
    done;
}

function aws_load_credentials() {
	export AWS_ACCESS_KEY_ID=$awskeyid
	export AWS_SECRET_ACCESS_KEY=$awssecret
}

function aws_upload() {
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
aws_load_credentials
aws_upload
aws_clean_up
travis_mark_end "UPLOADING BINARIES"
