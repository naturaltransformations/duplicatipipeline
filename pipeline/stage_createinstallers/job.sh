#!/bin/bash
. /pipeline/docker-run/markers.sh
. /pipeline/shared/duplicati.sh

function build_docker_installer () {
    installer_dir="${DUPLICATI_ROOT}/Installer/Docker/"
    ARCHITECTURES="amd64 arm32v7"

    unzip -qd "${installer_dir}/${RELEASE_NAME_SIMPLE}" "$ZIPFILE"

    cp -a /usr/bin/qemu-arm-static ${installer_dir}

    for arch in ${ARCHITECTURES}; do
        docker build \
            -t ${dockerrepo}:linux-${arch} \
            --build-arg ARCH=${arch}/ \
            --build-arg releaseversion=${releaseversion} \
            --build-arg releasetype=${releasetype} \
            --build-arg RELEASE_NAME_SIMPLE=${RELEASE_NAME_SIMPLE} \
            --file "${installer_dir}"/context/Dockerfile \
            ${installer_dir}
        docker save ${dockerrepo}:linux-${arch} > ${UPDATE_TARGET}/docker.linux-${arch}.tar
    done
}


function build_fedora_installer () {
    installer_dir="${DUPLICATI_ROOT}/Installer/fedora/"
    RPMBUILD="${installer_dir}/${RELEASE_NAME_SIMPLE}-rpmbuild"
    BUILDDATE=$(date +%Y%m%d)

    unzip -q -d "${installer_dir}/${RELEASE_NAME_SIMPLE}" "$ZIPFILE"

    cp ${installer_dir}/../debian/*-launcher.sh "${installer_dir}/${RELEASE_NAME_SIMPLE}"
    cp ${installer_dir}/../debian/duplicati.png "${installer_dir}/${RELEASE_NAME_SIMPLE}"
    cp ${installer_dir}/../debian/duplicati.desktop "${installer_dir}/${RELEASE_NAME_SIMPLE}"

    tar -cjf "${installer_dir}/${RELEASE_NAME_SIMPLE}.tar.bz2" -C ${installer_dir} "${RELEASE_NAME_SIMPLE}"

    mkdir -p "${RPMBUILD}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

    mv "${installer_dir}/${RELEASE_NAME_SIMPLE}.tar.bz2" "${RPMBUILD}/SOURCES/"
    cp "${installer_dir}"/duplicati.xpm "${RPMBUILD}/SOURCES/"
    cp "${installer_dir}"/make-binary-package.sh "${RPMBUILD}/SOURCES/duplicati-make-binary-package.sh"
    cp "${installer_dir}"/duplicati-install-recursive.sh "${RPMBUILD}/SOURCES/duplicati-install-recursive.sh"
    cp "${installer_dir}"/duplicati.service "${RPMBUILD}/SOURCES/duplicati.service"
    cp "${installer_dir}"/duplicati.default "${RPMBUILD}/SOURCES/duplicati.default"

    echo "%global _builddate ${BUILDDATE}" > "${RPMBUILD}/SOURCES/duplicati-buildinfo.spec"
    echo "%global _buildversion ${releaseversion}" >> "${RPMBUILD}/SOURCES/duplicati-buildinfo.spec"
    echo "%global _buildtag ${BUILDTAG}" >> "${RPMBUILD}/SOURCES/duplicati-buildinfo.spec"

    docker build -t "duplicati/fedora-build:latest" - < "${installer_dir}/Dockerfile.build"

    # Weirdness with time not being synced in Docker instance
    sleep 5
    docker run --rm \
        --workdir "/buildroot" \
        --volume "${workingdir}/Installer/fedora":"/buildroot":"rw" \
        --volume "${workingdir}/Installer/fedora/${RELEASE_NAME_SIMPLE}-rpmbuild":"/root/rpmbuild":"rw" \
        "duplicati/fedora-build:latest" \
        rpmbuild -bb duplicati-binary.spec

    mv "${RPMBUILD}/RPMS/noarch/"*.rpm ${UPDATE_TARGET}/
}


function build_debian_installer () {
	DEBNAME="duplicati_${releaseversion}-1_all.deb"
    DATE_STAMP=$(LANG=C date -R)
    installer_dir="${DUPLICATI_ROOT}/Installer/debian/"

    unzip -q -d "${installer_dir}/${RELEASE_NAME_SIMPLE}" "$ZIPFILE"

    cp -R "${installer_dir}/debian" "${installer_dir}/${RELEASE_NAME_SIMPLE}"
    cp "${installer_dir}/bin-rules.sh" "${installer_dir}/${RELEASE_NAME_SIMPLE}/debian/rules"
    sed -e "s;%VERSION%;${releaseversion};g" -e "s;%DATE%;$DATE_STAMP;g" "${installer_dir}/debian/changelog" > "${installer_dir}/${RELEASE_NAME_SIMPLE}/debian/changelog"

    touch "${installer_dir}/${RELEASE_NAME_SIMPLE}/releasenotes.txt"

    docker build -t "duplicati/debian-build:latest" - < "${installer_dir}/Dockerfile.build"

    # Weirdness with time not being synced in Docker instance
    sleep 5

    docker run --rm --workdir "/builddir/${RELEASE_NAME_SIMPLE}" --volume "${workingdir}/Installer/debian/":/builddir:rw "duplicati/debian-build:latest" dpkg-buildpackage

    mv "${installer_dir}/${DEBNAME}" "${UPDATE_TARGET}"
}


function build_synology_installer () {
    installer_dir="${DUPLICATI_ROOT}/Installer/Synology"
    DATE_STAMP=$(LANG=C date -R)
    BASE_FILE_NAME="${RELEASE_FILE_NAME%.*}"

    unzip -q -d "${installer_dir}/${RELEASE_NAME_SIMPLE}" "$ZIPFILE"

    # Remove items unused on the Synology platform
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/win-tools
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/SQLite/win64
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/SQLite/win32
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/MonoMac.dll
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/alphavss
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/OSX\ Icons
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/OSXTrayHost
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/AlphaFS.dll
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/AlphaVSS.Common.dll
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/licenses/alphavss
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/licenses/MonoMac
    rm -rf ${installer_dir}/${RELEASE_NAME_SIMPLE}/licenses/gpg

    # Install extra items for Synology
    cp -R ${installer_dir}/web-extra/* ${installer_dir}/${RELEASE_NAME_SIMPLE}/webroot/
    cp ${installer_dir}/dsm.duplicati.conf ${installer_dir}/${RELEASE_NAME_SIMPLE}

    DIRSIZE_KB=$(BLOCKSIZE=1024 du -s | cut -d '.' -f 1)
    let "DIRSIZE=DIRSIZE_KB*1024"

    tar cf ${installer_dir}/package.tgz -C "${installer_dir}/${RELEASE_NAME_SIMPLE}" "${installer_dir}/${RELEASE_NAME_SIMPLE}"/*

    ICON_72=$(openssl base64 -A -in "${installer_dir}"/PACKAGE_ICON.PNG)
    ICON_256=$(openssl base64 -A -in "${installer_dir}"/PACKAGE_ICON_256.PNG)

    echo "version=\"${releaseversion}\"" >> "${installer_dir}/INFO"
    MD5=$(md5sum "${installer_dir}/package.tgz" | awk -F ' ' '{print $NF}')
    echo "checksum=\"${MD5}\"" >> "${installer_dir}/INFO"
    echo "extractsize=\"${DIRSIZE_KB}\"" >> "${installer_dir}/INFO"
    echo "package_icon=\"${ICON_72}\"" >> "${installer_dir}/INFO"
    echo "package_icon_256=\"${ICON_256}\"" >> "${installer_dir}/INFO"

    chmod +x ${installer_dir}/scripts/*

    tar cf "${installer_dir}/${BASE_FILE_NAME}.spk" -C ${installer_dir} "${installer_dir}/"INFO "${installer_dir}/"LICENSE "${installer_dir}/"*.PNG \
    "${installer_dir}/"package.tgz "${installer_dir}/"scripts
    # TODO: These folders are not present in git: "${SCRIPT_DIR}/"conf "${SCRIPT_DIR}/"WIZARD_UIFILES . Remove?

    mv "${installer_dir}/${BASE_FILE_NAME}.spk" "${UPDATE_TARGET}"
}


for type in $(echo $installers | sed "s/,/ /g"); do
  travis_mark_begin "BUILDING $type PACKAGE"
	build_${type}_installer
  travis_mark_end "BUILDING $type PACKAGE"
done