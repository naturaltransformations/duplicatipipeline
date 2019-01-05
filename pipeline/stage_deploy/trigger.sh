#!/bin/bash
. error_handling.sh

PACKAGES="zip rsync awscli coreutils perl docker.io mono-complete gpg"
docker-run --image ubuntu \
--packages "$PACKAGES" \
--mountkeys \
--command "/pipeline/stage_deploy/job.sh" "$@"