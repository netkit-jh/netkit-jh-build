all:
	rootstrap ../build/root_fs

make-deb-tarball:
	debootstrap --exclude=pcmcia-cs,setserial wheezy . http://ftp.fr.debian.org/debian --make-tarball=latest_tarball.tgz
