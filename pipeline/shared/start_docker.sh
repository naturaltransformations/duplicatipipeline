#!/bin/bash
. "$( cd "$(dirname "$0")" ; pwd -P )/error_handling.sh"
. "$( cd "$(dirname "$0")" ; pwd -P )/markers.sh"

function pull_docker_image () {
  travis_mark_begin "PULL MINIMAL DOCKER IMAGE"
  docker pull $DOCKER_IMAGE
  travis_mark_end "PULL MINIMAL DOCKER IMAGE"
}

function add_option () {
  FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
  FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$2"
}

function add_volumes () {
  volume_args=()

  volume_args[${#volume_args[@]}]="-v /var/run/docker.sock:/var/run/docker.sock \
  -v ${TARGET_DIR}:/application \
  ${DOCKER_MOUNT_KEYS} \
  -v $( cd "$(dirname "$0")" ; pwd -P )/../:/pipeline ${DOCKER_SHARED_MEM}"

  for (( i=1; i<${#SOURCE_DIR[@]}+1; i++ )); do
    volume_args[${#volume_args[@]}]="-v ${SOURCE_DIR[$i-1]}:/source_$i"
  done
}

function run_with_docker () {
  if [ -z ${TARGET_DIR} ]; then
    echo "no target cache specified"
    exit 1
  fi

  add_volumes

  docker run ${volume_args[@]} \
  --privileged $DOCKER_AS_ROOT --rm $DOCKER_IMAGE "/pipeline/shared/runner.sh" "${FORWARD_OPTS[@]}"
}

function parse_options () {
  FORWARD_OPTS=()
  SOURCE_DIR=()

  while true ; do
      case "$1" in
      --dockerimage)
        DOCKER_IMAGE="$2"
        ;;
      --sourcedir)
        SOURCE_DIR[${#SOURCE_DIR[@]}]="$2"
        ;;
      --targetdir)
        TARGET_DIR="$2"
        ;;
      --dockerasroot)
        DOCKER_AS_ROOT="-u 0"
        ;;
      --dockermountkeys)
        DOCKER_MOUNT_KEYS="-v $( cd "$(dirname "$0")" ; pwd -P )/../../keys:/keys"
        ;;
      --dockersharedmem)
        DOCKER_SHARED_MEM="-v /dev/shm:/dev/shm"
        ;;
      --*)
        if [[ $2 =~ ^--.* || -z $2 ]]; then
          FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
        else
          FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
          FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$2"
        fi
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

  add_option "--gittag" "$(cd ${SOURCE_DIR[0]};git rev-parse --short HEAD)"
  add_option "--workingdir" "$TARGET_DIR"
  add_option "--sourcedirnum" ${#SOURCE_DIR[@]}
}

parse_options "$@"
pull_docker_image
run_with_docker