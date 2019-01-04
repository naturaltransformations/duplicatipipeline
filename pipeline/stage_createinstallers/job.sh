#!/bin/bash
. /pipeline/shared/duplicati.sh

parse_duplicati_options "$@"
get_value "installers"

for type in $(echo $installers | sed "s/,/ /g"); do
	"$( cd "$(dirname "$0")" ; pwd -P )"/installers-${type}.sh ${FORWARD_OPTS[@]}
done