#!/bin/bash
. /pipeline/shared/duplicati.sh
. /pipeline/shared/markers.sh

function append_json_installers () {
cat >> "${UPDATE_TARGET}/latest-installers.json" <<EOF
	"$2": {
		"name": "$1",
		"url": "https://updates.duplicati.com/${BUILDTYPE}/$1",
		"md5": "${MD5}",
		"sha1": "${SHA1}",
		"sha256": "${SHA256}"
	},
EOF
}

function close_json_installers () {
cat >> "${UPDATE_TARGET}/latest-installers.json" <<EOF
	"version": "${RELEASE_VERSION}"
}
EOF
}

function write_json_latest () {
cat > "${UPDATE_TARGET}/latest.json" <<EOF
{
	"version": "${RELEASE_VERSION}",
	"zip": "${RELEASE_FILE_NAME}.zip",
	"zipsig": "${RELEASE_FILE_NAME}.zip.sig",
	"zipsigasc": "${RELEASE_FILE_NAME}.zip.sig.asc",
	"manifest": "${RELEASE_FILE_NAME}.manifest",
	"urlbase": "https://updates.duplicati.com/${RELEASE_TYPE}/",
	"link": "https://updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip",
	"zipmd5": "${MD5}",
	"zipsha1": "${SHA1}",
	"zipsha256": "${SHA256}"
}
EOF
}

function sign_binaries_with_authenticode  () {
	if [ $SIGNED != true ]
	then
		return
	fi
  export AUTHENTICODE_PFXFILE="${HOME}/.config/signkeys/Duplicati/authenticode.pfx"
  export AUTHENTICODE_PASSWORD="${HOME}/.config/signkeys/Duplicati/authenticode.key"


	get_keyfile_password

	for exec in "${UPDATE_SOURCE}/Duplicati."*.exe; do
		sign_with_authenticode "${exec}"
	done
	for exec in "${UPDATE_SOURCE}/Duplicati."*.dll; do
		sign_with_authenticode "${exec}"
	done
}

function sign_with_authenticode () {

  #https://gist.github.com/trollixx/6abc5c3769c621ecc485
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

function sign_with_gpg () {
	gpg_sign_options="\
	 --inputfile=\"${1}\" \
	 --gpgkeyfile=\"${GPG_CREDENTIALS_FILE}\" \
	 --keyfile-password=\"${SIGNING_KEYFILE_PASSWORD}\" \
	 --gpgpath=\"${GPG_PATH}\" \
	"
	mono "${DUPLICATI_ROOT}/BuildTools/GnupgSigningTool/bin/Release/GnupgSigningTool.exe" --signaturefile=\"${1}.sig\" $gpg_sign_options
	mono "${DUPLICATI_ROOT}/BuildTools/GnupgSigningTool/bin/Release/GnupgSigningTool.exe" --signaturefile=\"${1}.sig.asc\" --armor $gpg_sign_options
}

function import_gpg_key () {
  mono /application/BuildTools/AutoUpdateBuilder/bin/Release/SharpAESCrypt.exe d "$SIGNING_KEYFILE_PASSWORD" "$GPG_KEY_FILE" |	"$GPG_PATH" --batch --import
}

function write_gpg_key_info () {
  GPG_ID=$(mono /application/BuildTools/AutoUpdateBuilder/bin/Release/SharpAESCrypt.exe d "$SIGNING_KEYFILE_PASSWORD" "$GPG_CREDENTIALS_FILE" | head -1)
	echo "${GPG_ID}" > "${SIG_FOLDER}/sign-key.txt"
	echo "https://pgp.mit.edu/pks/lookup?op=get&search=${GPG_ID}" >> "${SIG_FOLDER}/sign-key.txt"
}

function compute_hashes () {
		MD5=$(md5sum ${UPDATE_TARGET}/$1 | awk -F ' ' '{print $NF}' | tee "${SIG_FOLDER}/${1}.md5")
		SHA1=$(shasum -a 1 ${UPDATE_TARGET}/$1 | awk -F ' ' '{print $1}' | tee "${SIG_FOLDER}/${1}.sha1")
		SHA256=$(shasum -a 256 ${UPDATE_TARGET}/$1 | awk -F ' ' '{print $1}' | tee "${SIG_FOLDER}/${1}.sha256")
}

function compute_binary_metainfo () {
	#	sign_with_authenticode "${UPDATE_TARGET}/${MSI64NAME}"
  #	sign_with_authenticode "${UPDATE_TARGET}/${MSI32NAME}"

	SIG_FOLDER="duplicati-${BUILDTAG}-signatures"
	mkdir -p "${SIG_FOLDER}"

	echo "{" > "${UPDATE_TARGET}/latest-installers.json"

	for file in $(ls ${UPDATE_TARGET}/*.{zip,spk,rpm,deb}); do
		filename=$(basename "${file}")
    compute_hashes $filename
    sign_with_gpg $file

		append_json_installers
		if [ "${filename##*.}" == "zip" ]; then
  		write_json_latest
		fi
	done

  close_json_installers

	echo "duplicati_installers =" > "${UPDATE_TARGET}/latest-installers.js"
	cat "${UPDATE_TARGET}/latest-installers.json" >> "${UPDATE_TARGET}/latest-installers.js"
	echo ";" >> "${UPDATE_TARGET}/latest-installers.js"

	echo "duplicati_version_info =" > "${UPDATE_TARGET}/latest.js"
	cat "${UPDATE_TARGET}/latest.json" >> "${UPDATE_TARGET}/latest.js"
	echo ";" >> "${UPDATE_TARGET}/latest.js"
}


function parse_module_options () {
  while true ; do
      case "$1" in
	    --gpgpath)
   	  	GPG_PATH="$2"
	  	  ;;
  	  --gpgkeyfile)
     		GPG_KEY_FILE="$2"
	  	  ;;
  	  --gpgcredentialsfile)
     		GPG_CREDENTIALS_FILE="$2"
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

  export GPG_TTY=$(tty)
}

parse_duplicati_options "$@"
parse_module_options "${FORWARD_OPTS[@]}"

travis_mark_begin "SIGNING BINARIES"
import_gpg_key
compute_binary_metainfo
write_gpg_key_info
zip -r9 "${UPDATE_TARGET}/duplicati-${BUILDTAG}-signatures.zip" "${SIG_FOLDER}/"
travis_mark_end "SIGNING BINARIES"
