#!/bin/bash

source functions.sh && init
set -o nounset

target="/mnt/target"
root=$(blkid -L ROOT -o device)

metadata=/metadata
touch $metadata
curl --connect-timeout 60 http://$MIRROR_HOST:50061/metadata > $metadata
check_required_arg "$metadata" 'metadata file' '-M'

mkdir -p $target
mount -t ext4 $root $target

echo -e "${GREEN}#### Configuring cloud-init for Packet${NC}"

if [ -f $target/etc/cloud/cloud.cfg ]; then
	echo "Cloud-init post-install - pushing data from database to worker"
	mv $target/etc/cloud/cloud.cfg $target/etc/cloud/cloud.cfg.dpkg
	echo -e "#cloud-config\n\n" > $target/etc/cloud/cloud.cfg
	# yq search for cloud_cfg, reads as json, and prosses it as pretty yaml
	$(yq r -P $metadata "cloud_cfg" >> $target/etc/cloud/cloud.cfg)
else
	echo "Cloud-init post-install -  default cloud.cfg does not exist!"
fi

if [ -f $target/etc/init/cloud-init-nonet.conf ]; then
	sed -i 's/dowait 120/dowait 1/g' $target/etc/init/cloud-init-nonet.conf
		sed -i 's/dowait 10/dowait 1/g' $target/etc/init/cloud-init-nonet.conf
else
	echo "Cloud-init post-install - cloud-init-nonet does not exist. Skipping edit"
fi

cat <<EOF >$target/etc/cloud/cloud.cfg.d/90_dpkg.cfg
# datasource_list: [ NoCloud, AltCloud, ConfigDrive, OpenStack, CloudStack, DigitalOcean, Ec2, MAAS, OVF, GCE, None ]
datasource_list: [ NoCloud, None ]
EOF
