
function upload_installers_to_aws() {
	process_installer() {
		if [ "$2" != "zip" ]; then
			aws --profile=duplicati-upload s3 cp "${UPDATE_TARGET}/$1" "s3://updates.duplicati.com/${BUILDTYPE}/$1"
		fi

		local MD5=$(md5 ${UPDATE_TARGET}/$1 | awk -F ' ' '{print $NF}')
		local SHA1=$(shasum -a 1 ${UPDATE_TARGET}/$1 | awk -F ' ' '{print $1}')
		local SHA256=$(shasum -a 256 ${UPDATE_TARGET}/$1 | awk -F ' ' '{print $1}')

cat >> "./tmp/latest-installers.json" <<EOF
	"$2": {
		"name": "$1",
		"url": "https://updates.duplicati.com/${BUILDTYPE}/$1",
		"md5": "${MD5}",
		"sha1": "${SHA1}",
		"sha256": "${SHA256}"
	},
EOF
	}

	mkdir "./tmp"

	echo "{" > "./tmp/latest-installers.json"

	process_installer "${ZIPFILE}" "zip"
	process_installer "${SPKNAME}" "spk"
	process_installer "${RPMNAME}" "rpm"
	process_installer "${DEBNAME}" "deb"
	process_installer "${DMGNAME}" "dmg"
	process_installer "${PKGNAME}" "pkg"
	process_installer "${MSI32NAME}" "msi86"
	process_installer "${MSI64NAME}" "msi64"
    aws --profile=duplicati-upload s3 cp "${ZIP_FILE_WITH_SIGNATURES}" "s3://updates.duplicati.com/${BUILDTYPE}/${ZIP_FILE_WITH_SIGNATURES}"

cat >> "./tmp/latest-installers.json" <<EOF
	"version": "${VERSION}"
}
EOF

	echo "duplicati_installers =" > "./tmp/latest-installers.js"
	cat "./tmp/latest-installers.json" >> "./tmp/latest-installers.js"
	echo ";" >> "./tmp/latest-installers.js"

	aws --profile=duplicati-upload s3 cp "./tmp/latest-installers.json" "s3://updates.duplicati.com/${BUILDTYPE}/latest-installers.json"
	aws --profile=duplicati-upload s3 cp "./tmp/latest-installers.js" "s3://updates.duplicati.com/${BUILDTYPE}/latest-installers.js"
}

function upload_binaries_to_aws () {
	echo "Uploading binaries"
	aws --profile=duplicati-upload s3 cp "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip" "s3://updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip"
	aws --profile=duplicati-upload s3 cp "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip.sig" "s3://updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip.sig"
	aws --profile=duplicati-upload s3 cp "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip.sig.asc" "s3://updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip.sig.asc"
	aws --profile=duplicati-upload s3 cp "${UPDATE_TARGET}/${RELEASE_FILE_NAME}.manifest" "s3://updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.manifest"

	aws --profile=duplicati-upload s3 cp "s3://updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.manifest" "s3://updates.duplicati.com/${RELEASE_TYPE}/latest.manifest"

	ZIP_MD5=$(md5 ${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip | awk -F ' ' '{print $NF}')
	ZIP_SHA1=$(shasum -a 1 ${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip | awk -F ' ' '{print $1}')
	ZIP_SHA256=$(shasum -a 256 ${UPDATE_TARGET}/${RELEASE_FILE_NAME}.zip | awk -F ' ' '{print $1}')

cat > "latest.json" <<EOF
{
	"version": "${RELEASE_VERSION}",
	"zip": "${RELEASE_FILE_NAME}.zip",
	"zipsig": "${RELEASE_FILE_NAME}.zip.sig",
	"zipsigasc": "${RELEASE_FILE_NAME}.zip.sig.asc",
	"manifest": "${RELEASE_FILE_NAME}.manifest",
	"urlbase": "https://updates.duplicati.com/${RELEASE_TYPE}/",
	"link": "https://updates.duplicati.com/${RELEASE_TYPE}/${RELEASE_FILE_NAME}.zip",
	"zipmd5": "${ZIP_MD5}",
	"zipsha1": "${ZIP_SHA1}",
	"zipsha256": "${ZIP_SHA256}"
}
EOF

	echo "duplicati_version_info =" > "latest.js"
	cat "latest.json" >> "latest.js"
	echo ";" >> "latest.js"

	aws --profile=duplicati-upload s3 cp "latest.json" "s3://updates.duplicati.com/${RELEASE_TYPE}/latest.json"
	aws --profile=duplicati-upload s3 cp "latest.js" "s3://updates.duplicati.com/${RELEASE_TYPE}/latest.js"
}
