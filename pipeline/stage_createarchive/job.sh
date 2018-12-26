#!/bin/bash
. /pipeline/shared/markers.sh
. /pipeline/shared/duplicati.sh

function update_version_files() {
	echo "${RELEASE_NAME}" > "${DUPLICATI_ROOT}/Duplicati/License/VersionTag.txt"
	echo "${RELEASE_TYPE}" > "${DUPLICATI_ROOT}/Duplicati/Library/AutoUpdater/AutoUpdateBuildChannel.txt"
	UPDATE_MANIFEST_URLS="https://updates.duplicati.com/${RELEASE_TYPE}/latest.manifest;https://alt.updates.duplicati.com/${RELEASE_TYPE}/latest.manifest"
	echo "${UPDATE_MANIFEST_URLS}" > "${DUPLICATI_ROOT}/Duplicati/Library/AutoUpdater/AutoUpdateURL.txt"
	cp "${DUPLICATI_ROOT}/Updates/release_key.txt"  "${DUPLICATI_ROOT}/Duplicati/Library/AutoUpdater/AutoUpdateSignKey.txt"
}

function sign_binaries_with_authenticode  () {
	if [ $SIGNED != true ]
	then
		return
	fi

	get_keyfile_password

	for exec in "${UPDATE_SOURCE}/Duplicati."*.exe; do
		sign_with_authenticode "${exec}"
	done
	for exec in "${UPDATE_SOURCE}/Duplicati."*.dll; do
		sign_with_authenticode "${exec}"
	done
}

function set_gpg_autoupdate_options () {
	if [[ $SIGNED != true ]]
	then
		return
	fi

	get_keyfile_password
	UPDATER_KEYFILE="/keys/updater-release.key"
	auto_update_options="$auto_update_options --gpgkeyfile=\"${GPG_KEYFILE}\" --gpgpath=\"${GPG}\""
}

function generate_package () {
	UPDATE_ZIP_URLS="https://updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip;https://alt.updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip"

	mkdir -p "${UPDATE_TARGET}"

	auto_update_options="--input=\"${UPDATE_SOURCE}\" --output=\"${UPDATE_TARGET}\"  \
	 --manifest=${DUPLICATI_ROOT}/Updates/${RELEASE_TYPE}.manifest --changeinfo=\"${RELEASE_CHANGEINFO}\" \
	 --displayname=\"${RELEASE_NAME}\" \
	 --remoteurls=\"${UPDATE_ZIP_URLS}\" --version=\"${RELEASE_VERSION}\" --allow-new-key=true \
	 --keyfile-password=\"${SIGNING_KEYFILE_PASSWORD}\" \
	 --keyfile=\"${SIGNING_KEYFILE}\""

	set_gpg_autoupdate_options

	# if zip is not written, non-zero return code will cause script to stop
	mono "${DUPLICATI_ROOT}/BuildTools/AutoUpdateBuilder/bin/Release/AutoUpdateBuilder.exe" $auto_update_options

	mv "${UPDATE_TARGET}/package.zip" "${UPDATE_TARGET}/latest.zip"
	mv "${UPDATE_TARGET}/autoupdate.manifest" "${UPDATE_TARGET}/latest.manifest"
	cp "${UPDATE_TARGET}/latest.zip" "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip"
	cp "${UPDATE_TARGET}/latest.manifest" "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.manifest"

	if $SIGNED
	then
		mv "${UPDATE_TARGET}/package.zip.sig" "${UPDATE_TARGET}/latest.zip.sig"
		mv "${UPDATE_TARGET}/package.zip.sig.asc" "${UPDATE_TARGET}/latest.zip.sig.asc"
		cp "${UPDATE_TARGET}/latest.zip.sig" "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip.sig"
		cp "${UPDATE_TARGET}/latest.zip.sig.asc" "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip.sig.asc"
	fi
}

function prepare_update_source_folder () {
	mkdir -p "${UPDATE_SOURCE}"

	cp -R "${DUPLICATI_ROOT}/Duplicati/GUI/Duplicati.GUI.TrayIcon/bin/Release/"* "${UPDATE_SOURCE}"
	cp -R "${DUPLICATI_ROOT}Duplicati/Server/webroot" "${UPDATE_SOURCE}"

	# We copy some files for alphavss manually as they are not picked up by xbuild
	mkdir -p "${UPDATE_SOURCE}/alphavss"
	for FN in "${DUPLICATI_ROOT}/Duplicati/Library/Snapshots/bin/Release/"AlphaVSS.*.dll; do
		cp "${FN}" "${UPDATE_SOURCE}/alphavss/"
	done

	# Fix for some support libraries not being picked up
	for BACKEND in "${DUPLICATI_ROOT}/Duplicati/Library/Backend/"*; do
		if [ -d "${BACKEND}/bin/Release/" ]; then
			cp "${BACKEND}/bin/Release/"*.dll "${UPDATE_SOURCE}"
		fi
	done

	# Install the assembly redirects for all Duplicati .exe files
	find "${UPDATE_SOURCE}" -maxdepth 1 -type f -name Duplicati.*.exe -exec cp ${DUPLICATI_ROOT}/Installer/AssemblyRedirects.xml {}.config \;

	# Clean some unwanted build files
	for FILE in "control_dir" "Duplicati-server.sqlite" "Duplicati.debug.log" "updates"; do
		if [ -e "${UPDATE_SOURCE}/${FILE}" ]; then rm -rf "${UPDATE_SOURCE}/${FILE}"; fi
	done

	# Clean the localization spam from Azure
	for FILE in "de" "es" "fr" "it" "ja" "ko" "ru" "zh-Hans" "zh-Hant"; do
		if [ -e "${UPDATE_SOURCE}/${FILE}" ]; then rm -rf "${UPDATE_SOURCE}/${FILE}"; fi
	done

	# Clean debug files, if any
	rm -rf "${UPDATE_SOURCE}/"*.mdb "${UPDATE_SOURCE}/"*.pdb "${UPDATE_SOURCE}/"*.xml
}

function parse_module_options () {
  while true ; do
      case "$1" in
      --signingkeyfile)
        SIGNING_KEYFILE="$2"
        ;;
      --signingkeyfilepassword)
        SIGNING_KEYFILE_PASSWORD="$2"
        ;;
      "" )
        break
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

parse_module_options "$@"
parse_duplicati_options "${FORWARD_OPTS[@]}"


travis_mark_begin "BUILDING ZIP"
update_version_files
prepare_update_source_folder
sign_binaries_with_authenticode
generate_package
travis_mark_end "BUILDING ZIP"
