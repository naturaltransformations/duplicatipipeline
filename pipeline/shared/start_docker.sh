#!/bin/bash
. "$( cd "$(dirname "$0")" ; pwd -P )/error_handling.sh"
. "$( cd "$(dirname "$0")" ; pwd -P )/markers.sh"

function pull_docker_image () {
  travis_mark_begin "PULL MINIMAL DOCKER IMAGE"
  docker pull $DOCKER_IMAGE
  travis_mark_end "PULL MINIMAL DOCKER IMAGE"
}

function run_with_docker () {
  if [ -z ${TARGET_CACHE} ]; then
    echo "no target cache specified"
    exit 1
  fi

  declare -a volume_args

  volume_args[${#volume_args[@]}]="-v /var/run/docker.sock:/var/run/docker.sock \
  -v ${TARGET_CACHE}:/application \
  ${DOCKER_MOUNT_KEYS} \
  -v $( cd "$(dirname "$0")" ; pwd -P )/../:/pipeline ${DOCKER_SHARED_MEM}"

  for (( i=1; i<${#SOURCE_CACHE[@]}+1; i++ )); do
    volume_args[${#volume_args[@]}]="-v ${SOURCE_CACHE[$i-1]}:/source_$i"
  done

  docker run -e WORKING_DIR="$TARGET_CACHE" ${volume_args[@]} -e NUM_SOURCE_CACHES=${#SOURCE_CACHE[@]} \
  --privileged $DOCKER_AS_ROOT --rm $DOCKER_IMAGE "/pipeline/shared/runner.sh" "${FORWARD_OPTS[@]}"
}

function parse_options () {
  FORWARD_OPTS=()
  SOURCE_CACHE=()


  while true ; do
      case "$1" in
      --dockerimage)
        DOCKER_IMAGE="$2"
        ;;
      --sourcecache)
        SOURCE_CACHE[${#SOURCE_CACHE[@]}]="$2"
        ;;
      --targetcache)
        TARGET_CACHE="$2"
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
      esac
      if [[ $2 =~ ^--.* || -z $2 ]]; then
        FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
        shift
      else
        FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
        FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$2"
        shift
        shift
      fi
      if [[ -z $1 ]]; then
        break
      fi
  done
}

parse_options "$@"
pull_docker_image
run_with_docker