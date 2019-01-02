#!/bin/bash
. /pipeline/shared/duplicati.sh
. /pipeline/shared/markers.sh

function build_installer () {
    installer_dir="${DUPLICATI_ROOT}/Installer/Synology"
    DATE_STAMP=$(LANG=C date -R)
    BASE_FILE_NAME="${RELEASE_FILE_NAME%.*}"

    unzip -q -d "${installer_dir}/${RELEASE_NAME_SIMPLE}" "$ZIPFILE"

    install_oem_files "${installer_dir}" "${RELEASE_NAME_SIMPLE}"

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

    echo "version=\"${RELEASE_VERSION}\"" >> "${installer_dir}/INFO"
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

travis_mark_begin "BUILDING SYNOLOGY PACKAGE"
build_installer
travis_mark_end "BUILDING SYNOLOGY PACKAGE"