#!/bin/bash

source functions.sh && init
set -o nounset

# defaults
# shellcheck disable=SC2207
disks=($(lsblk -dno name -e1,7,11 | sed 's|^|/dev/|' | sort))
userdata='/dev/null'

arch=$(uname -m)

metadata=/metadata
touch $metadata
curl --connect-timeout 60 http://$MIRROR_HOST:50061/metadata > $metadata
check_required_arg "$metadata" 'metadata file' '-M'

declare class && set_from_metadata class 'facility.plan_slug' <"$metadata"
declare deprovision_fast="false"
declare facility && set_from_metadata facility 'facility.facility_code' <"$metadata"
declare distro && set_from_metadata distro 'instance.operating_system_version.distro' <"$metadata"
declare os_slug && set_from_metadata os_slug 'instance.operating_system_version.os_slug' <"$metadata"
declare os_codename && set_from_metadata os_codename 'instance.operating_system_version.os_codename' <"$metadata"
declare preserve_data="false"
declare pwhash && set_from_metadata pwhash 'instance.crypted_root_password' <"$metadata"
declare state && set_from_metadata state 'state' <"$metadata"

echo "Number of drives found: ${#disks[*]}"
if ((${#disks[*]} != 0)); then
	echo "Disk candidate check successful"
fi

ephemeral=/workflow/data.json
echo "{}" > $ephemeral
echo $(jq ". + {\"arch\": \"$arch\"}" <<< cat $ephemeral) > $ephemeral
echo $(jq ". + {\"class\": \"$class\"}" <<< cat $ephemeral) > $ephemeral
echo $(jq ". + {\"deprovision_fast\": \"$deprovision_fast\"}" <<< cat $ephemeral) > $ephemeral
echo $(jq ". + {\"facility\": \"$facility\"}" <<< cat $ephemeral) > $ephemeral
echo $(jq ". + {\"distro\": \"$distro\"}" <<< cat $ephemeral) > $ephemeral
echo $(jq ". + {\"os_slug\": \"$os_slug\"}" <<< cat $ephemeral) > $ephemeral
echo $(jq ". + {\"os_codename\": \"$os_codename\"}" <<< cat $ephemeral) > $ephemeral
echo $(jq ". + {\"preserve_data\": \"$preserve_data\"}" <<< cat $ephemeral) > $ephemeral
echo $(jq ". + {\"pwhash\": \"$pwhash\"}" <<< cat $ephemeral) > $ephemeral
echo $(jq ". + {\"state\": \"$state\"}" <<< cat $ephemeral) > $ephemeral

jq . $ephemeral

custom_image=false
target="/mnt/target"
cprconfig=/tmp/config.cpr
cprout=/statedir/cpr.json

echo "Using default image since no cpr_url provided"
jq -c '.instance.storage' "$metadata" >$cprconfig

if ! [[ -f /statedir/disks-partioned-image-extracted ]]; then
        jq . $cprconfig

        # make sure the disks are ok to use
        assert_block_or_loop_devs "${disks[@]}"
        assert_same_type_devs "${disks[@]}"

        is_uefi && uefi=true || uefi=false

        if [[ $deprovision_fast == false ]] && [[ $preserve_data == false ]]; then
                echo -e "${GREEN}Checking disks for existing partitions...${NC}"
                if fdisk -l "${disks[@]}" 2>/dev/null | grep Disklabel >/dev/null; then
                        echo -e "${RED}Critical: Found pre-exsting partitions on a disk. Aborting install...${NC}"
                        fdisk -l "${disks[@]}"
                        exit 1
                fi
        fi

        echo "Disk candidates are ready for partitioning."

        echo -e "${GREEN}#### Running CPR disk config${NC}"
        UEFI=$uefi ./cpr.sh $cprconfig "$target" "$preserve_data" "$deprovision_fast" | tee $cprout

        mount | grep $target

        # dump cpr provided fstab into $target
        mkdir -p /mnt/target/etc
        touch  /mnt/target/etc/fstab
        jq -r .fstab "$cprout" >$target/etc/fstab

	echo "backup /etc/fstab file to restore it in after step install-root-fs cause install-root-fs will override the fstab content"
	cp /mnt/target/etc/fstab /mnt/target/etc/fstab_backup
	echo "$(cat /mnt/target/etc/fstab)"
	echo -e "${GREEN}#### CPR disk config complete ${NC}"
fi
