SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
. "${SCRIPT_DIR}/../shared.sh"

function build () {
    # build version stamper
	msbuild /property:Configuration=Release "${DUPLICATI_ROOT}/BuildTools/UpdateVersionStamp/UpdateVersionStamp.csproj"
	mono "${DUPLICATI_ROOT}/BuildTools/UpdateVersionStamp/bin/Release/UpdateVersionStamp.exe" --version="${RELEASE_VERSION}"

	# build autoupdate
	nuget restore "${DUPLICATI_ROOT}/BuildTools/AutoUpdateBuilder/AutoUpdateBuilder.sln"
	nuget restore "${DUPLICATI_ROOT}/Duplicati.sln"
	msbuild /p:Configuration=Release "${DUPLICATI_ROOT}/BuildTools/AutoUpdateBuilder/AutoUpdateBuilder.sln"

	msbuild /p:DefineConstants=__MonoCS__ /p:DefineConstants=ENABLE_GTK /p:Configuration=Release "${DUPLICATI_ROOT}/Duplicati.sln"

    msbuild /p:Configuration=Release "${DUPLICATI_ROOT}"/Duplicati.sln
    cp -r "${DUPLICATI_ROOT}"/Duplicati/Server/webroot "${DUPLICATI_ROOT}"/Duplicati/GUI/Duplicati.GUI.TrayIcon/bin/Release/webroot
}

parse_options "$@"

travis_mark_begin "BUILDING BINARIES"
eval build $IF_QUIET_SUPPRESS_OUTPUT
travis_mark_end "BUILDING BINARIES"