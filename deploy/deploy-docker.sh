function deploy_docker () {
	ARCHITECTURES="amd64 arm32v7"

	for arch in $ARCHITECTURES; do
    	tags="linux-${arch}-${VERSION} linux-${arch}-${CHANNEL}"
		for tag in $tags; do
	        docker push ${REPOSITORY}:${tag}
		done
	done
}
