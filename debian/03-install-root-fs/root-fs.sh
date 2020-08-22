#!/bin/bash

source functions.sh && init
set -o nounset

ephemeral="/workflow/data.json"
pwhash=$(jq -r .pwhash "$ephemeral")
distro=$(jq -r .distro "$ephemeral")
os_slug=$(jq -r .os_slug "$ephemeral")
os_codename=$(jq -r .os_codename "$ephemeral")

assetdir="/tmp/assets"
grmlconfig="grml-$distro.tar.gz"
grmldir="/etc/debootstrap"

root=$(blkid -L ROOT -o device)
disk=$(blkid -L ROOT -o device | tr -dc 'a-z /')

if ! [[ -f /statedir/disks-partioned-image-extracted ]]; then
	echo -e "${GREEN}#### Retrieving grml-debootstrap variables ...${NC}"
	mkdir $assetdir
	wget "$BASEURL/$grmlconfig" -P $assetdir
	tar -zxpf "$assetdir/$grmlconfig" -C $grmldir

	echo -e "${GREEN}#### Install ${os_slug} ( ${os_codename} ) root-fs to ${root} ...${NC}"
	export http_proxy="http://$PROXY_HOST:3142"
	export https_proxy="http://$PROXY_HOST:3142"
	grml-debootstrap --release $os_codename --target $root --grub $disk --password $pwhash --nointerfaces --remove-configs --force
	echo -e "${GREEN}#### root-fs deployment completed ...${NC}"
fi
