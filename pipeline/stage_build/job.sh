#!/bin/bash
. /pipeline/shared/markers.sh
. /pipeline/shared/duplicati.sh

function build () {
    nuget restore "${DUPLICATI_ROOT}"/Duplicati.sln

    if [ ! -d "${DUPLICATI_ROOT}"/packages/SharpCompress.0.18.2 ]; then
        ln -s "${DUPLICATI_ROOT}"/packages/sharpcompress.0.18.2 "${DUPLICATI_ROOT}"/packages/SharpCompress.0.18.2
    fi

    # build version stamper
	msbuild /property:Configuration=Release "${DUPLICATI_ROOT}/BuildTools/UpdateVersionStamp/UpdateVersionStamp.csproj"
	mono "${DUPLICATI_ROOT}/BuildTools/UpdateVersionStamp/bin/Release/UpdateVersionStamp.exe" --version="${RELEASE_VERSION}"

	# build autoupdate
	nuget restore "${DUPLICATI_ROOT}/BuildTools/AutoUpdateBuilder/AutoUpdateBuilder.sln"
    msbuild /p:Configuration=Release "${DUPLICATI_ROOT}/BuildTools/AutoUpdateBuilder/AutoUpdateBuilder.sln"

    # build gpg signing tool
	nuget restore "${DUPLICATI_ROOT}/BuildTools/GnupgSigningTool/GnupgSigningTool.sln"
    msbuild /p:Configuration=Release "${DUPLICATI_ROOT}/BuildTools/GnupgSigningTool/GnupgSigningTool.sln"

    # build duplicati
	msbuild /p:DefineConstants=__MonoCS__ /p:DefineConstants=ENABLE_GTK /p:Configuration=Release "${DUPLICATI_ROOT}/Duplicati.sln"

    msbuild /p:Configuration=Release "${DUPLICATI_ROOT}"/Duplicati.sln
    cp -r "${DUPLICATI_ROOT}"/Duplicati/Server/webroot "${DUPLICATI_ROOT}"/Duplicati/GUI/Duplicati.GUI.TrayIcon/bin/Release/webroot
}

parse_duplicati_options "$@"

travis_mark_begin "BUILDING BINARIES"
build
travis_mark_end "BUILDING BINARIES"