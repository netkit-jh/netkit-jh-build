#!/bin/bash

# Check that NETKIT_HOME is set
if [ -z "${NETKIT_HOME}" ]; then
	echo "NETKIT_HOME is not configured, please ensure you have run the installation script and reloaded your environmental variables."
	exit 1
fi

# Check netkit.conf exists
if [ ! -f "${NETKIT_HOME}/netkit.conf" ]; then
	echo "${NETKIT_HOME}/netkit.conf does not exist, please try running the installation script again."
fi

echo ""
echo "Which terminal emulator would you like to use for Netkit machines?

(1) xterm - reliable, stable but ancient UI (default installation)
(2) alacritty - lightweight, modern UI (recommended)
(3) kitty -  another lightweight, modern UI
(4) gnome-terminal - default terminal of Ubuntu 
(5) wsl - wsl compatiblity through windows conhost
(6) wt - wsl compatability through windows terminal (recommended for wsl hosts)

You will be asked to enter your password to install new repositories/packages where required.
"
successful=false

while [ $successful = false ]; do
	echo "Which terminal would you like to use (1/2/3/4/5)? "
	read terminal
	
	case $terminal in
		1)
			# xterm is available on Ubuntu by default
			sudo apt install xterm -y
			sed -i "s/TERM_TYPE=[a-zA-Z]*/TERM_TYPE=xterm/g" ${NETKIT_HOME}/netkit.conf
			successful=true
			terminal="Xterm"
		;;
		2)
		 	# Requires the alacritty repo
			sudo add-apt-repository ppa:mmstick76/alacritty
			sudo apt update
			sudo apt install alacritty -y
			sed -i "s/TERM_TYPE=[a-zA-Z]*/TERM_TYPE=alacritty/g" ${NETKIT_HOME}/netkit.conf
			successful=true
			terminal="Alacritty"
			echo "
If you get 'libEGL warning: DRI2: failed to authenticate' when running a machine, try running 'apt upgrade'. This is a harmless warning related to virtual machine graphical drivers and will not impact running the lab."
		;;
		3)
			# Kitty is available on Ubuntu by default
			sudo apt install kitty -y
			sed -i "s/TERM_TYPE=[a-zA-Z]*/TERM_TYPE=kitty/g" ${NETKIT_HOME}/netkit.conf
			successful=true
			terminal="Kitty"
		;;
		4)
			# gnome is pre installed
			sed -i "s/TERM_TYPE=[a-zA-Z]*/TERM_TYPE=gnome/g" ${NETKIT_HOME}/netkit.conf
			successful=true
			terminal="Gnome"
		;;
		5)
			# check if we're on a wsl host
			if which wsl.exe > /dev/null; then
				sed -i "s/TERM_TYPE=[a-zA-Z]*/TERM_TYPE=wsl/g" ${NETKIT_HOME}/netkit.conf
				successful=true
				terminal="Windows Conhost"
			else
				echo "You are not on a wsl host."
			fi
		;;
		6)
			# check if we're on a wsl host
			if which wsl.exe > /dev/null; then
				# check if windows terminal is present on the Windows host
				if which wt.exe > /dev/null; then
					sed -i "s/TERM_TYPE=[a-zA-Z]*/TERM_TYPE=wt/g" ${NETKIT_HOME}/netkit.conf
					successful=true
					terminal="Windows Terminal"
				else
					echo "Windows Terminal was not detected on your Windows Host"
					echo "Please install it by following the instructions at"
					echo "https://docs.microsoft.com/en-us/windows/terminal/get-started"
			else
				echo "You are not on a wsl host."
			fi
		;;
		*)
			echo "Please pick one of the available options."
		;;
	esac
done

echo "
Done! Your Netkit installation has been updated and you are now using ${terminal} as your terminal emulator."
