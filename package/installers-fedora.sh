#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/utils.sh"

function build_installer () {
    installer_dir="${DUPLICATI_ROOT}/BuildTools/Installer/fedora/"
    RPMBUILD="${installer_dir}/${RELEASE_NAME_SIMPLE}-rpmbuild"
    BUILDDATE=$(date +%Y%m%d)

    unzip -q -d "${installer_dir}/${RELEASE_NAME_SIMPLE}" "$ZIPFILE"

    cp ${installer_dir}/../debian/*-launcher.sh "${installer_dir}/${RELEASE_NAME_SIMPLE}"
    cp ${installer_dir}/../debian/duplicati.png "${installer_dir}/${RELEASE_NAME_SIMPLE}"
    cp ${installer_dir}/../debian/duplicati.desktop "${installer_dir}/${RELEASE_NAME_SIMPLE}"

    install_oem_files "${installer_dir}/" "${installer_dir}/${RELEASE_NAME_SIMPLE}"
    tar -cjf "${installer_dir}/${RELEASE_NAME_SIMPLE}.tar.bz2" -C ${installer_dir} "${RELEASE_NAME_SIMPLE}"

    mkdir -p "${RPMBUILD}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

    mv "${installer_dir}/${RELEASE_NAME_SIMPLE}.tar.bz2" "${RPMBUILD}/SOURCES/"
    cp "${installer_dir}"/duplicati.xpm "${RPMBUILD}/SOURCES/"
    cp "${installer_dir}"/make-binary-package.sh "${RPMBUILD}/SOURCES/duplicati-make-binary-package.sh"
    cp "${installer_dir}"/duplicati-install-recursive.sh "${RPMBUILD}/SOURCES/duplicati-install-recursive.sh"
    cp "${installer_dir}"/duplicati.service "${RPMBUILD}/SOURCES/duplicati.service"
    cp "${installer_dir}"/duplicati.default "${RPMBUILD}/SOURCES/duplicati.default"

    echo "%global _builddate ${BUILDDATE}" > "${RPMBUILD}/SOURCES/duplicati-buildinfo.spec"
    echo "%global _buildversion ${RELEASE_VERSION}" >> "${RPMBUILD}/SOURCES/duplicati-buildinfo.spec"
    echo "%global _buildtag ${BUILDTAG}" >> "${RPMBUILD}/SOURCES/duplicati-buildinfo.spec"

    docker build -t "duplicati/fedora-build:latest" - < "${installer_dir}/Dockerfile.build"

    # Weirdness with time not being synced in Docker instance
    sleep 5
    docker run  --rm \
        --workdir "/buildroot" \
        --volume "${WORKING_DIR}/BuildTools/Installer/fedora":"/buildroot":"rw" \
        --volume "${WORKING_DIR}/BuildTools/Installer/fedora/${RELEASE_NAME_SIMPLE}-rpmbuild":"/root/rpmbuild":"rw" \
        "duplicati/fedora-build:latest" \
        rpmbuild -bb duplicati-binary.spec

    cp "${RPMBUILD}/RPMS/noarch/"*.rpm ${UPDATE_TARGET}/
}

parse_options "$@"

travis_mark_begin "BUILDING FEDORA PACKAGE"
build_installer
travis_mark_end "BUILDING FEDORA PACKAGE"