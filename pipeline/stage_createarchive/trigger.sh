#!/bin/bash
. error_handling.sh

PACKAGES="rsync"
docker-run --image mono \
--packages "$PACKAGES" \
--volume $( cd "$(dirname "$0")" ; pwd -P )/../../keys:/keys \
--command "/pipeline/stage_createarchive/job.sh" "$@"