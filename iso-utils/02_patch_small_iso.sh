#!/bin/bash 

MCP="${1}"

if [[ -z ${MCP} ]]
then
  echo "You need to provide the Machine Config Pool to be attached to the ISO. e.g: $0 worker-cnf"
  exit 1
fi

IGNITION_FILE="${MCP}-small.ign"

if [[ -z ${BUILD_FOLDER} ]]
then
    SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
    BUILD_FOLDER=${SCRIPTPATH}/../build
fi

python3 create_iso_ignition.py
# Add custom scripts for configuring the static IPs
SCRIPT_IGN_JSON=$(cat ign-files/script-ign)
SERVICE_IGN_JSON=$(cat ign-files/systemd-unit-ign)
CSV_INVENTORY_IGN_JSON=$(cat ign-files/csv-inventory-ign)
NETWORK_MANAGER_CONF_IGN_JSON=$(cat ign-files/network-manager-onprem-ign)

if [[ -z ${SCRIPT_IGN_JSON} || -z ${SERVICE_IGN_JSON} || -z ${CSV_INVENTORY_IGN_JSON} || -z ${NETWORK_MANAGER_CONF_IGN_JSON} ]]
then
  echo "Some ignition config is missing"
  exit 1
fi

mv iso.ign ${BUILD_FOLDER}/

# Add static ip configuration script and ipv6 csv inventory file
cat ${BUILD_FOLDER}/iso.ign | jq ".storage.files += [${SCRIPT_IGN_JSON},${CSV_INVENTORY_IGN_JSON},${NETWORK_MANAGER_CONF_IGN_JSON}]" > ${BUILD_FOLDER}/temp.ign
# Add systemd unit for running the ip configuration script upon boot
cat ${BUILD_FOLDER}/temp.ign | jq ".systemd.units += [${SERVICE_IGN_JSON}]" > ${BUILD_FOLDER}/${IGNITION_FILE}

# Clean the temporary stuff
rm -f ${BUILD_FOLDER}/{iso.ign,temp.ign,config.ign}

