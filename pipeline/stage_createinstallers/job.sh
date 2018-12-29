#!/bin/bash
. /pipeline/shared/duplicati.sh


function parse_module_options () {
  while true ; do
      case "$1" in
      --installers)
        INSTALLERS="$2"
        ;;
      * )
        break
        ;;
      esac
      if [[ $2 =~ ^--.* || -z $2 ]]; then
        shift
      else
        shift
        shift
      fi
  done
}

parse_duplicati_options "$@"
parse_module_options "${FORWARD_OPTS[@]}"

for type in $(echo $INSTALLERS | sed "s/,/ /g"); do
	"$( cd "$(dirname "$0")" ; pwd -P )"/installers-${type}.sh ${FORWARD_OPTS[@]}
done