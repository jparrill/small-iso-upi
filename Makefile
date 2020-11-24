DEST_SERVER ?= 10.19.0.88
ACTION ?= off
API_EP ?= api.mgmt-hub.e2e.bos.redhat.com
WEBSERVER ?= [2620:52:0:1304::1]
BMC_USER ?= aW3s0m3U53R
BMC_PASS ?= aW3s0m3P4SS
ISO ?= worker-cnf-small.iso
WS_PATH ?= /var/www/html
MCP ?= worker-cnf
ROOT_FOLDER := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD_FOLDER ?= ${ROOT_FOLDER}/build

.EXPORT_ALL_VARIABLES:

default: recreate

all: recreate sleep server_action sleep remount

recreate:
	bash ./01_create_small_iso.sh ${API_EP} ${WEBSERVER}
	cd iso-utils; bash ./02_patch_small_iso.sh
	sudo cp -r ${BUILD_FOLDER}/${ISO} ${WS_PATH}/${ISO}
	[[ ! -f ${BUILD_FOLDER}/rootfs.img ]] || sudo cp -r ${BUILD_FOLDER}/rootfs.img ${WS_PATH}/rootfs.img
	sudo cp -r ${BUILD_FOLDER}/${MCP}-small.ign ${WS_PATH}/${MCP}-small.ign

remount:
	sudo podman run --net=host idracbootfromiso -r ${DEST_SERVER} -u ${BMC_USER} -p ${BMC_PASS} -i http://${WEBSERVER}/${ISO} -d

server_action:
	ipmitool -H ${DEST_SERVER} -U ${BMC_USER} -P ${BMC_PASS} -I lanplus power ${ACTION}

clear_jobs:
	sudo podman run --net=host --entrypoint="racadm -r ${DEST_SERVER} -u ${BMC_USER} -p ${BMC_PASS} jobqueue delete -i JID_CLEARALL_FORCE" idracbootfromiso                                                                                                                                                               

sleep:
	sleep 2

