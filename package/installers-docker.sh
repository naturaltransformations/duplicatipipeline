#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/utils.sh"

function build_installer () {
    installer_dir="${DUPLICATI_ROOT}/BuildTools/Installer/Docker/"
    ARCHITECTURES="amd64 arm32v7"
    DEFAULT_ARCHITECTURE=amd64
    DEFAULT_RELEASE_TYPE=beta
    REPOSITORY=duplicati/duplicati

    unzip -qd "${installer_dir}/${RELEASE_NAME_SIMPLE}" "$ZIPFILE"

    install_oem_files "${installer_dir}/" "${installer_dir}/${RELEASE_NAME_SIMPLE}"

    cp -a /usr/bin/qemu-arm-static ${installer_dir}

    for arch in ${ARCHITECTURES}; do
        tags="linux-${arch}-${RELEASE_VERSION} linux-${arch}-${RELEASE_TYPE}"
        if [ ${RELEASE_TYPE} = ${DEFAULT_RELEASE_TYPE} ]; then
            tags="linux-${arch}-latest ${tags}"
        fi
        if [ ${arch} = ${DEFAULT_ARCHITECTURE} ]; then
            tags="${RELEASE_VERSION} ${RELEASE_TYPE} ${tags}"
        fi
        if [ ${RELEASE_TYPE} = ${DEFAULT_RELEASE_TYPE} -a ${arch} = ${DEFAULT_ARCHITECTURE} ]; then
            tags="latest ${tags}"
        fi

        args=""
        for tag in ${tags}; do
            args="-t ${REPOSITORY}:${tag} ${args}"
        done

        docker build \
            ${args} \
            --build-arg ARCH=${arch}/ \
            --build-arg RELEASE_VERSION=${RELEASE_VERSION} \
            --build-arg RELEASE_TYPE=${RELEASE_TYPE} \
            --build-arg RELEASE_NAME_SIMPLE=${RELEASE_NAME_SIMPLE} \
            --file "${installer_dir}"/context/Dockerfile \
            ${installer_dir}
    done
}

parse_options "$@"

travis_mark_begin "BUILDING DOCKER PACKAGE"
build_installer
travis_mark_end "BUILDING DOCKER PACKAGE"