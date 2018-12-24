#!/bin/bash
. "$( cd "$(dirname "$0")" ; pwd -P )/../shared/error_handling.sh"

export DUPLICATI_ROOT="/application/"
declare -a FORWARD_OPTS

function get_keyfile_password () {
	if [ "z${KEYFILE_PASSWORD}" == "z" ]; then
		echo -n "Enter keyfile password: "
		read -s KEYFILE_PASSWORD
		echo

        if [ "z${KEYFILE_PASSWORD}" == "z" ]; then
            echo "No password entered, quitting"
            exit 0
        fi

        export KEYFILE_PASSWORD
	fi
}

function set_gpg_data () {
	if [[ $SIGNED != true ]]; then
		return
	fi

	get_keyfile_password

	GPGDATA=$(mono "BuildTools/AutoUpdateBuilder/bin/Debug/SharpAESCrypt.exe" d "${KEYFILE_PASSWORD}" "${GPG_KEYFILE}")
	if [ ! $? -eq 0 ]; then
		echo "Decrypting GPG keyfile failed"
		exit 1
	fi
	GPGID=$(echo "${GPGDATA}" | head -n 1)
	GPGKEY=$(echo "${GPGDATA}" | head -n 2 | tail -n 1)
}

function sign_with_authenticode () {
	if [ ! -f "${AUTHENTICODE_PFXFILE}" ] || [ ! -f "${AUTHENTICODE_PASSWORD}" ]; then
		echo "Skipped authenticode signing as files are missing"
		return
	fi

	echo "Performing authenticode signing of installers"

    get_keyfile_password

	if [ "z${PFX_PASS}" == "z" ]; then
        PFX_PASS=$("${MONO}" "${DUPLICATI_ROOT}/BuildTools/AutoUpdateBuilder/bin/Debug/SharpAESCrypt.exe" d "${KEYFILE_PASSWORD}" "${AUTHENTICODE_PASSWORD}")

        DECRYPT_STATUS=$?
        if [ "${DECRYPT_STATUS}" -ne 0 ]; then
            echo "Failed to decrypt, SharpAESCrypt gave status ${DECRYPT_STATUS}, exiting"
            exit 4
        fi

        if [ "x${PFX_PASS}" == "x" ]; then
            echo "Failed to decrypt, SharpAESCrypt gave empty password, exiting"
            exit 4
        fi
    fi

	NEST=""
	for hashalg in sha1 sha256; do
		SIGN_MSG=$(osslsigncode sign -pkcs12 "${AUTHENTICODE_PFXFILE}" -pass "${PFX_PASS}" -n "Duplicati" -i "http://www.duplicati.com" -h "${hashalg}" ${NEST} -t "http://timestamp.verisign.com/scripts/timstamp.dll" -in "$1" -out tmpfile)
		if [ "${SIGN_MSG}" != "Succeeded" ]; then echo "${SIGN_MSG}"; fi
		mv tmpfile "${ZIPFILE}"
		NEST="-nest"
	done
}

install_oem_files () {
    SOURCE_DIR=$1
    TARGET_DIR=$2
    for n in "../oem" "../../oem" "../../../oem"
    do
        if [ -d "${SOURCE_DIR}/$n" ]; then
            echo "Installing OEM files"
            cp -R "${SOURCE_DIR}/$n" "${TARGET_DIR}/webroot/"
        fi
    done

    for n in "oem-app-name.txt" "oem-update-url.txt" "oem-update-key.txt" "oem-update-readme.txt" "oem-update-installid.txt"
    do
        for p in "../$n" "../../$n" "../../../$n"
        do
            if [ -f "${SOURCE_DIR}/$p" ]; then
                echo "Installing OEM override file"
                cp "${SOURCE_DIR}/$p" "${TARGET_DIR}"
            fi
        done
    done
}

function parse_duplicati_options () {
  RELEASE_VERSION="2.0.4.$(cat "$DUPLICATI_ROOT"/Updates/build_version.txt)"
  RELEASE_TYPE="canary"
  SIGNED=false

  while true ; do
      case "$1" in
      --unsigned)
        SIGNED=false
        ;;
      --version)
        RELEASE_VERSION="$2"
        ;;
      --releasetype)
        RELEASE_TYPE="$2"
        ;;
      "" )
        break
        ;;
      esac
      FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$1"
      FORWARD_OPTS[${#FORWARD_OPTS[@]}]="$2"
      shift
      shift
  done

  export RELEASE_VERSION="$RELEASE_VERSION"
  export RELEASE_TYPE="$RELEASE_TYPE"
  export RELEASE_CHANGELOG_FILE="${DUPLICATI_ROOT}/changelog.txt"
  export RELEASE_CHANGELOG_NEWS_FILE="${DUPLICATI_ROOT}/changelog-news.txt" # never in repo due to .gitignore
  export RELEASE_TIMESTAMP=$(date +%Y-%m-%d)
  export RELEASE_NAME="${RELEASE_VERSION}_${RELEASE_TYPE}_${RELEASE_TIMESTAMP}"
  export RELEASE_FILE_NAME="duplicati-${RELEASE_NAME}"
  export RELEASE_NAME_SIMPLE="duplicati-${RELEASE_VERSION}"
  export UPDATE_SOURCE="${DUPLICATI_ROOT}/Updates/build/${RELEASE_TYPE}_source-${RELEASE_VERSION}"
  export UPDATE_TARGET="${DUPLICATI_ROOT}/Updates/build/${RELEASE_TYPE}_target-${RELEASE_VERSION}"
  export ZIPFILE="${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip"
  export DOCKER_REPOSITORY="duplicatiautomated/duplicati"
#  BUILDTAG_RAW=$(echo "${RELEASE_FILE_NAME}" | cut -d "." -f 1-4 | cut -d "-" -f 2-4)
  export AUTHENTICODE_PFXFILE="${HOME}/.config/signkeys/Duplicati/authenticode.pfx"
  export AUTHENTICODE_PASSWORD="${HOME}/.config/signkeys/Duplicati/authenticode.key"
  export GPG_KEYFILE="${HOME}/.config/signkeys/Duplicati/updater-gpgkey.key"
  export GPG=/usr/local/bin/gpg2
  # Newer GPG needs this to allow input from a non-terminal
  export GPG_TTY=$(tty)
}
