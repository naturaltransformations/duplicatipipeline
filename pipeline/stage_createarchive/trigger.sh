#!/bin/bash
. error_handling.sh

PACKAGES="rsync"
docker-run --image mono \
--packages "$PACKAGES" \
--mountkeys \
--command "/pipeline/stage_createarchive/job.sh" "$@"