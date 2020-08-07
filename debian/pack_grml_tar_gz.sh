#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as sudo ./pack_grml_tar_gz.sh"
   exit 1
fi

grmlvars="grml.tar.gz"
sourcedir="03-install-root-fs"
targetdir="temp"

mkdir $targetdir

for this in chroot-script config packages
do
	cp -a $sourcedir/$this $targetdir
	chown root:root $targetdir/$this
done

cd $targetdir
chmod +x chroot-script
tar -czvf ../$grmlvars .
cd ..
rm -R $targetdir


