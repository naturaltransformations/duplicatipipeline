#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/utils.sh"

function build_installer () {
    installer_dir="${DUPLICATI_ROOT}/BuildTools/Installer/Synology"
    DATE_STAMP=$(LANG=C date -R)
    BASE_FILE_NAME="${RELEASE_FILE_NAME%.*}"
    TMPRELEASE_NAME_SIMPLE="${installer_dir}/${BASE_FILE_NAME}-extract"

    TIMESERVER="http://timestamp.synology.com/timestamp.php"

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


    set_gpg_data

    if [ "z${GPGID}" != "z" ]; then
        # Now codesign the spk file
        mkdir "${TMPRELEASE_NAME_SIMPLE}"
        tar xf "${BASE_FILE_NAME}.spk" -C "${TMPRELEASE_NAME_SIMPLE}"
        # Sort on macOS does not have -V / --version-sort
        # https://stackoverflow.com/questions/4493205/unix-sort-of-version-numbers
        SORT_OPTIONS="-t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n"

        cat $(find ${TMPRELEASE_NAME_SIMPLE} -type f | sort ${SORT_OPTIONS}) > "${BASE_FILE_NAME}.spk.tmp"

        gpg2 --ignore-time-conflict --ignore-valid-from --yes --batch --armor --detach-sign --default-key="${GPGID}" --output "${BASE_FILE_NAME}.signature" "${BASE_FILE_NAME}.spk.tmp"
        rm "${BASE_FILE_NAME}.spk.tmp"

        curl --silent --form "file=@${BASE_FILE_NAME}.signature" "${TIMESERVER}" > "${TMPRELEASE_NAME_SIMPLE}/syno_signature.asc"
        rm "${BASE_FILE_NAME}.signature"

        rm "${BASE_FILE_NAME}.spk"
        tar cf "${BASE_FILE_NAME}.spk" -C "${TMPRELEASE_NAME_SIMPLE}" $(ls -1 ${TMPRELEASE_NAME_SIMPLE})

        rm -rf "${TMPRELEASE_NAME_SIMPLE}"
    fi

    mv "${installer_dir}/${BASE_FILE_NAME}.spk" "${UPDATE_TARGET}"
}

parse_options "$@"

travis_mark_begin "BUILDING SYNOLOGY PACKAGE"
build_installer
travis_mark_end "BUILDING SYNOLOGY PACKAGE"