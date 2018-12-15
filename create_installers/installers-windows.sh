
exit 0

# function build_windows_installer () {
# 	# Pre-boot virtual machine
# 	echo "Booting Win10 build instance"
# 	VBoxHeadless --startvm Duplicati-Win10-Build &

# 	echo ""
# 	echo ""
# 	echo "Building Windows instance in virtual machine"

# 	while true
# 	do
# 		ssh -o ConnectTimeout=5 IEUser@192.168.56.101 "dir"
# 		if [ $? -eq 255 ]; then
# 			echo "Windows Build machine is not responding, try restarting it"
# 			read -p "Press [Enter] key to try again"
# 			continue
# 		fi
# 		break
# 	done

# 	MSI64NAME="duplicati-${BUILDTAG_RAW}-x64.msi"
# 	MSI32NAME="duplicati-${BUILDTAG_RAW}-x86.msi"

# cat > "tmp-windows-commands.bat" <<EOF
# SET VS120COMNTOOLS=%VS140COMNTOOLS%
# cd \\Duplicati\\Installer\\Windows
# build-msi.bat "../../$1"
# EOF

# 	ssh IEUser@192.168.56.101 "\\Duplicati\\tmp-windows-commands.bat"
# 	ssh IEUser@192.168.56.101 "shutdown /s /t 0"

# 	rm "tmp-windows-commands.bat"

# 	mv "./Installer/Windows/Duplicati.msi" "${UPDATE_TARGET}/${MSI64NAME}"
# 	mv "./Installer/Windows/Duplicati-32bit.msi" "${UPDATE_TARGET}/${MSI32NAME}"

# 	VBoxManage controlvm "Duplicati-Win10-Build" poweroff
# }
