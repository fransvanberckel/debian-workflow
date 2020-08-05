#!/bin/bash

packages=(
        apt-utils
        curl
        dmidecode
        efibootmgr
        file
        gawk
        gdisk
	gnupg
        grml-debootstrap
        isc-dhcp-client
        jq
        lsb-release
        mdadm
        nano
        python3-urllib3
        wget
	yq
)
echo "${packages[@]}"
