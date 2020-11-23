#!/bin/bash

function generate_csv_ign() {
    CSV_FILE=${1}
    CSV_DEST=/var/tmp/AI_STATIC_INV
    IGN_FILE=${SCRIPTPATH}/iso-utils/ign-files/csv-inventory-ign
    
    if [ -z $CSV_FILE ]
    then
      echo "You need to provide a CSV inventory file"
      exit 1
    fi
    echo "Generating ignition file using $CSV_FILE inventory file"
    CSV_BASE_64=$(openssl base64 -A -in ${CSV_FILE})
    cat <<EOF > $IGN_FILE
{"overwrite": true,"path": "${CSV_DEST}","mode": 292,"user": {"name": "root"},"contents": { "source": "data:;base64,${CSV_BASE_64}"}}
EOF
    echo "Ignition file generated at ${IGN_FILE}"
}


function report() {
    echo "----------------------"
    echo "The generated files that you will need to host are the following: "
    echo "ISO: ${OUTPUT}" 
    echo "IGN: ${IGNITION_FILE}"
    echo "ROOTFS: ${ROOTFS}"
}

#if [[ $(id -u) -ne 0 ]]
#then
#  echo "This script must be run as root"
#  exit 1
#fi

API_IP="${1}"

if [[ -z ${API_IP} ]]
then
  echo "You need to pass the API DNS record as parameter. e.g: $0 api.cluster.example.com 2620:52:0:1304::5"
  exit 1
fi

IP_WS="${2}"

if [[ -z ${IP_WS} ]]
then
  echo "You need to provide the IPv6 for your web server hosting the ignition configs and rootfs. e.g: $0 api.cluster.example.com 2620:52:0:1304::5"
  exit 1
fi 

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
export BUILD_FOLDER=${SCRIPTPATH}/build
IP="[${IP_WS}]"
ROOTFS="http://${IP}/rootfs.img"
MCP="worker-cnf"
IGNITION_FILE="http://${IP}/${MCP}-small.ign"
OUTPUT="${BUILD_FOLDER}/${MCP}-small.iso"
BASE="/tmp/base.iso"
OCP_VERSION="4.6.3"

# IP for booting the server and being able to reach the rootfs img"
EXTRA_ARGS="ip=[2620:52:0:1304::8]::[2620:52:0:1304::fe]:64:small-iso:enp3s0f0:none nameserver=[2620:52:0:1304::1]"

if [ -d ${BUILD_FOLDER} ]
then
  echo "Cleaning build folder"
  rm -rf ${BUILD_FOLDER}
fi

mkdir -p ${BUILD_FOLDER}

if [ ! -f ${BUILD_FOLDER}/rootfs.img ]
then
  echo "Downloading rootfs"
  curl -Lk https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.6/latest/rhcos-${OCP_VERSION}-x86_64-live-rootfs.x86_64.img -o ${BUILD_FOLDER}/rootfs.img
fi

curl -H "Accept: application/vnd.coreos.ignition+json; version=3.1.0" -Lk https://${API_IP}:22623/config/${MCP} -o ${BUILD_FOLDER}/config.ign

if [[ ! -f ${BUILD_FOLDER}/config.ign ]]
then
    echo "config.ign file was not downloaded from the Hub cluster. WARNING: Using Sample file from iso-utils folder"
    exit 1
fi

generate_csv_ign "${SCRIPTPATH}/ipv6-inventory.csv"
sudo rm -rf /tmp/base.iso ${OUTPUT} /tmp/syslinux* /tmp/coreos ztp-iso-generator
sudo yum -y install git xorriso syslinux
git clone https://github.com/redhat-ztp/ztp-iso-generator.git ${BUILD_FOLDER}/ztp-iso-generator
cd ${BUILD_FOLDER}/ztp-iso-generator/rhcos-iso
sudo -E ./generate_rhcos_iso.sh ${BASE}
sudo -E ./inject_config_files.sh ${BASE} ${OUTPUT} ${IGNITION_FILE} ${ROOTFS} "${EXTRA_ARGS}"

report
