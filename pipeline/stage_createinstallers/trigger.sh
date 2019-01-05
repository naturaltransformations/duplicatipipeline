#!/bin/bash
. error_handling.sh

docker-run --image ubuntu \
--packages "qemu-user qemu-user-static unzip rsync bzip2 docker.io" \
--command "/pipeline/stage_createinstallers/job.sh" "$@"