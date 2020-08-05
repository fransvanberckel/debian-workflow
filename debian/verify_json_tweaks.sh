#!/usr/bin/env bash

# verify json exit codes
# 0 - Success
# 1 - Failed
# 4 - Invalid

if [ $(cat hardware.json | jq empty > /dev/null 2>&1; echo $?) -eq 0 ]; then
	echo "The JSON syntax is valid"
else
	echo "Your JSON tweaks are invalid ..."
	cat hardware.json | jq empty 2>&1;
fi
