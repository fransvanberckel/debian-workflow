#!/bin/bash

grmlvars="grml.tar.gz"
sourcedir="03-install-root-fs"
targetdir="temp"

mkdir $targetdir

for this in chroot-script config packages
do
	cp -a $sourcedir/$this $targetdir
done

cd $targetdir
chmod +x chroot-script
tar -czvf ../$grmlvars .
cd ..
rm -R $targetdir


