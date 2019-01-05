#!/bin/bash
. error_handling.sh

#PACKAGES="zip rsync coreutils perl mono-complete gpg curl"
docker-run --image naturaltransformations/ubuntu_sign \
--mountkeys \
--command "/pipeline/stage_sign/job.sh" "$@"