#!/bin/bash
. error_handling.sh

PACKAGES="python-pip rsync mono-complete"
docker-run --image selenium/standalone-firefox \
--packages "$PACKAGES" \
--asroot \
--sharedmem \
--command "sudo -u seluser /pipeline/stage_integrationtests/job.sh" "$@"