#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared/utils.sh"

function build_file_signatures() {
	if [ "z${GPGID}" != "z" ]; then
		echo "$GPGKEY" | "${GPG}" "--passphrase-fd" "0" "--batch" "--yes" "--default-key=${GPGID}" "--output" "$2.sig" "--detach-sig" "$1"
		echo "$GPGKEY" | "${GPG}" "--passphrase-fd" "0" "--batch" "--yes" "--default-key=${GPGID}" "--armor" "--output" "$2.sig.asc" "--detach-sig" "$1"
	fi

	md5 "$1" | awk -F ' ' '{print $NF}' > "$2.md5"
	shasum -a 1 "$1" | awk -F ' ' '{print $1}' > "$2.sha1"
	shasum -a 256 "$1" | awk -F ' ' '{print $1}'  > "$2.sha256"
}

function sign_with_gpg () {
	ZIP_FILE_WITH_SIGNATURES="${UPDATE_TARGET}/duplicati-${BUILDTAG_RAW}-signatures.zip"
	SIG_FOLDER="duplicati-${BUILDTAG_RAW}-signatures"
	mkdir -p "./tmp/${SIG_FOLDER}"

	for FILE in $(ls ${UPDATE_TARGET}); do
		build_file_signatures "${FILE}" "./tmp/${SIG_FOLDER}/${FILE}"
	done

	if [ "z${GPGID}" != "z" ]; then
		echo "${GPGID}" > "./tmp/${SIG_FOLDER}/sign-key.txt"
		echo "https://pgp.mit.edu/pks/lookup?op=get&search=${GPGID}" >> "./tmp/${SIG_FOLDER}/sign-key.txt"
	fi

	zip -r9 "${ZIP_FILE_WITH_SIGNATURES}" "./tmp/${SIG_FOLDER}/"

	rm -rf "./tmp"
}

parse_options "$@"

for type in $(echo $INSTALLERS | sed "s/,/ /g"); do
	echo $type
	${SCRIPT_DIR}/installers-${type}.sh $FORWARD_OPTS
done

if [ $SIGNED = true ]; then
	GPG=/usr/local/bin/gpg2
	set_gpg_data

	sign_with_gpg

	sign_with_authenticode "${UPDATE_TARGET}/${MSI64NAME}"
	sign_with_authenticode "${UPDATE_TARGET}/${MSI32NAME}"
fi