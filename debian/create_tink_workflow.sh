#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as sudo ./create_tink_workflow.sh"
   exit 1
fi

export OS_CODENAME=bullseye
export MAC_ADDRESS=00:1d:21:58:43:5d

read -sp 'Enter new root password ... ' PASS
printf "\n"
read -sp 'Enter new password salt ... ' SALT
printf "\n"

export UUID=$(uuidgen|tr "[:upper:]" "[:lower:]")
export SALTEDPASSWD=$(printf '%s\n' "$PASS" | mkpasswd --stdin --method=sha-512 --salt "$SALT")
echo "Generate $UUID.json"
cat ./hardware.json | envsubst  > $UUID.json

echo "Creating new Tinkerbell worker environment"
docker exec -i deploy_tink-cli_1 tink hardware push < ./$UUID.json
rm $UUID.json

docker exec -i deploy_tink-cli_1 tink template create --name $OS_CODENAME < ./$OS_CODENAME.yml | tee ./template.txt

TEMPLATE_ID=$(cat ./template.txt | awk '/Created/{printf "%s", $3}' && rm ./template.txt)
docker exec -i deploy_tink-cli_1 tink workflow create --hardware '{"device_1":"'$MAC_ADDRESS'"}' --template "$TEMPLATE_ID" | tee ./workflow.txt
