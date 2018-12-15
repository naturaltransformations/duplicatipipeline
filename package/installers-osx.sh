#!/bin/sh

exit 0

#
# DMG building script adopted from:
#   http://el-tramo.be/git/fancy-dmg/plain/Makefile
#

ZIPFILE=$1
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
WC_DMG="${SCRIPT_DIR}/wc.dmg"
WC_DIR="${SCRIPT_DIR}/wc"
TEMPLATE_DMG=template.dmg
TEMPLATE_DMG_BZ2=${TEMPLATE_DMG}.bz2
OUTPUT_DMG=Duplicati.dmg
OUTPUT_PKG=Duplicati.pkg
UNWANTED_FILES="AlphaVSS.Common.dll AlphaFS.dll AlphaFS.dll.config AlphaVSS.Common.dll.config appindicator-sharp.dll SQLite win-tools alphavss control_dir Duplicati.sqlite Duplicati-server.sqlite run-script-example.bat lvm-scripts Duplicati.debug.log SVGIcons"

CODESIGN_IDENTITY=2S6R28R577

SHOW_USAGE_ERROR=

DELETE_DMG=0

if [ -f "${SCRIPT_DIR}/$TEMPLATE_DMG_BZ2" ]; then
    rm -rf "${SCRIPT_DIR}/$TEMPLATE_DMG"

    bzip2 --decompress --keep --quiet "${SCRIPT_DIR}/$TEMPLATE_DMG_BZ2"
    DELETE_DMG=1
fi

if [ ! -f "${SCRIPT_DIR}/$TEMPLATE_DMG" ]; then
    echo "Template file $TEMPLATE_DMG not found"
    exit
fi

if [ ! -f "$ZIPFILE" ]; then
    echo "Please supply a packaged zip file as the first input argument"
    exit
fi

ZIPNAME=$(basename "$ZIPFILE")
VERSION_NUMBER=$(echo "$ZIPNAME" | awk -F- '{print $2}' | awk -F_ '{print $1}')
VERSION_NAME="Duplicati"

rm -rf "${SCRIPT_DIR}/${OUTPUT_DMG}"
rm -rf "${SCRIPT_DIR}/${OUTPUT_PKG}"

# Remove any existing work copy
rm -rf "${SCRIPT_DIR}/Duplicati.app"

# Create folder structure
mkdir -p "${SCRIPT_DIR}/Duplicati.app/Contents/MacOS"
mkdir -p "${SCRIPT_DIR}/Duplicati.app/Contents/Resources"

# Extract the zip into the Resouces folder
unzip -q "$ZIPFILE" -d "${SCRIPT_DIR}/Duplicati.app/Contents/Resources"

# Install the Info.plist and icon, patch the plist file as well
PLIST=$(cat "${SCRIPT_DIR}/Info.plist")
PLIST=${PLIST//!LONG_VERSION!/${VERSION_NUMBER}}
echo ${PLIST} > "${SCRIPT_DIR}/Duplicati.app/Contents/Info.plist"
cp "${SCRIPT_DIR}/Duplicati.icns" "${SCRIPT_DIR}/Duplicati.app/Contents/Resources"

. "${SCRIPT_DIR}/../../scripts/common.sh"
install_oem_files "${SCRIPT_DIR}" "${SCRIPT_DIR}/Duplicati.app/Contents/Resources"

# Install the LauncAgent if anyone needs it
cp -R "${SCRIPT_DIR}/daemon" "${SCRIPT_DIR}/Duplicati.app/Contents/Resources"

# Install executables
cp "${SCRIPT_DIR}/run-with-mono.sh" "${SCRIPT_DIR}/Duplicati.app/Contents/MacOS/"
cp "${SCRIPT_DIR}/Duplicati-trayicon-launcher" "${SCRIPT_DIR}/Duplicati.app/Contents/MacOS/duplicati"
cp "${SCRIPT_DIR}/Duplicati-commandline-launcher" "${SCRIPT_DIR}/Duplicati.app/Contents/MacOS/duplicati-cli"
cp "${SCRIPT_DIR}/Duplicati-server-launcher" "${SCRIPT_DIR}/Duplicati.app/Contents/MacOS/duplicati-server"
cp "${SCRIPT_DIR}/uninstall.sh" "${SCRIPT_DIR}/Duplicati.app/Contents/MacOS/"

chmod +x "${SCRIPT_DIR}/Duplicati.app/Contents/MacOS/"*

# Remove some of the files that we do not like
for FILE in $UNWANTED_FILES
do
    rm -rf "${SCRIPT_DIR}/Duplicati.app/Contents/Resources/${FILE}"
done

# Codesign the app bundle
if [ "x${CODESIGN_IDENTITY}" != "x" ]; then
    echo "Codesigning application bundle"

    #Do a poke to get sudo prompt up before the long-running sign-process
    UNUSED=$(sudo ls)

    # Codesign all resources in bundle (i.e. the actual code)
    # Not required, but nice-to-have
    find "${SCRIPT_DIR}/Duplicati.app/Contents/Resources" -type f -print0 | xargs -0 codesign -s "${CODESIGN_IDENTITY}"

    # These files have dependencies, so we need to sign them in the correct order
    for file in "duplicati-cli" "duplicati-server" "run-with-mono.sh" "uninstall.sh"; do
        codesign -s "${CODESIGN_IDENTITY}" "${SCRIPT_DIR}/Duplicati.app/Contents/MacOS/${file}"
    done

    # Then sign the whole package
    codesign -s "${CODESIGN_IDENTITY}" "${SCRIPT_DIR}/Duplicati.app"
else
    echo "No codesign identity supplied, skipping bundle signing"
fi

# Set permissions
sudo chown -R root:admin "${SCRIPT_DIR}/Duplicati.app"
sudo chown -R root:wheel "${SCRIPT_DIR}/daemon/com.duplicati.app.launchagent.plist"
sudo chmod -R 644 "${SCRIPT_DIR}/daemon/com.duplicati.app.launchagent.plist"
sudo chmod +x "${SCRIPT_DIR}"/daemon-scripts/postinstall
sudo chmod +x "${SCRIPT_DIR}"/daemon-scripts/preinstall
sudo chmod +x "${SCRIPT_DIR}"/app-scripts/postinstall
sudo chmod +x "${SCRIPT_DIR}"/app-scripts/preinstall

rm -rf "${SCRIPT_DIR}/DuplicatiApp.pkg"
rm -rf "${SCRIPT_DIR}/DuplicatiDaemon.pkg"

# Make a PKG file, commented out lines can be uncommented to re-generate the lists
#pkgbuild --analyze --root "./Duplicati.app" --install-location /Applications/Duplicati.app "InstallerComponent.plist"
pkgbuild --scripts app-scripts --identifier com.duplicati.app --root "${SCRIPT_DIR}/Duplicati.app" --install-location /Applications/Duplicati.app --component-plist "InstallerComponent.plist" "DuplicatiApp.pkg"
pkgbuild --scripts daemon-scripts --identifier com.duplicati.app.daemon --root "${SCRIPT_DIR}/daemon" --install-location /Library/LaunchAgents "DuplicatiDaemon.pkg"

#productbuild --synthesize --package "DuplicatiApp.pkg" "Distribution.xml"
productbuild --distribution "${SCRIPT_DIR}/Distribution.xml" --package-path "." --resources "." "${OUTPUT_PKG}"

# Alternate to allow fixing the package
#productbuild --distribution "Distribution.xml" --package-path . "DuplicatiTmp.pkg"
#pkgutil --expand "DuplicatiTmp.pkg" "DuplicatiIntermediate"
#pkgutil --flatten "DuplicatiIntermediate" "Duplicati.pkg"
#rm -rf "DuplicatiTmp.pkg"

rm -rf "${SCRIPT_DIR}/DuplicatiApp.pkg"
rm -rf "${SCRIPT_DIR}/DuplicatiDaemon.pkg"

if [ "x${CODESIGN_IDENTITY}" != "x" ]; then
    echo "Codesigning installer package"
    productsign --sign "${CODESIGN_IDENTITY}" "${OUTPUT_PKG}" "${OUTPUT_PKG}.signed"
    mv "${OUTPUT_PKG}.signed" "${OUTPUT_PKG}"
else
    echo "No codesign identity supplied, skipping package signing"
fi

# Prepare a new dmg
echo "Building dmg"
if [ "$DELETE_DMG" -eq "1" ]
then
    # If we have just extracted the dmg, use that as working copy
    WC_DMG=$TEMPLATE_DMG
else
    # Otherwise we want a copy so we kan keep the original fresh
    cp "$TEMPLATE_DMG" "$WC_DMG"
fi

# Make a mount point and mount the new dmg
mkdir -p "${SCRIPT_DIR}/$WC_DIR"
hdiutil attach "${SCRIPT_DIR}/$WC_DMG" -noautoopen -quiet -mountpoint "${SCRIPT_DIR}/$WC_DIR"

# Change the dmg name
echo "Setting dmg name to $VERSION_NAME"
diskutil quiet rename wc "$VERSION_NAME"

# Make the Duplicati.app structure, root folder should exist
rm -rf "${WC_DIR}/Duplicati.app"

# Move in the prepared folder
sudo mv "${SCRIPT_DIR}/Duplicati.app" "${WC_DIR}/Duplicati.app"

# Unmount the dmg
hdiutil detach "$WC_DIR" -quiet -force

# Compress the dmg
hdiutil convert "$WC_DMG" -quiet -format UDZO -imagekey zlib-level=9 -o "${OUTPUT_DMG}"

# Clean up
rm -rf "$WC_DMG"
rm -rf "$WC_DIR"

if [ "x${CODESIGN_IDENTITY}" != "x" ]; then
    echo "Codesigning DMG image"
    codesign -s "${CODESIGN_IDENTITY}" "${OUTPUT_DMG}"
else
    echo "No codesign identity supplied, skipping DMG signing"
fi


echo "Done, created ${OUTPUT_DMG}"


	DMGNAME="duplicati-${BUILDTAG_RAW}.dmg"
	PKGNAME="duplicati-${BUILDTAG_RAW}.pkg"





	mv "${DUPLICATI_ROOT}/BuildTools/Installer/OSX/Duplicati.dmg" "../../${UPDATE_TARGET}/${DMGNAME}"
	mv "${DUPLICATI_ROOT}/BuildTools/Installer/OSX/Duplicati.pkg" "../../${UPDATE_TARGET}/${PKGNAME}"
