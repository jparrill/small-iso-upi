DEST_SERVER ?= 10.19.0.88
ACTION ?= off
API_EP ?= api.mgmt-hub.e2e.bos.redhat.com
WEBSERVER ?= 2620:52:0:1304::1
BMC_USER ?= aW3s0m3U53R
BMC_PASS ?= aW3s0m3P4SS
ISO ?= worker-cnf-small.iso
WS_PATH ?= /var/www/html/

.EXPORT_ALL_VARIABLES:


default: recreate

all: recreate sleep server_action move_artifacts sleep remount

move_artifacts:
	cp build/{${ISO},rootfs.img,config.ign} ${WS_PATH}

recreate:
	bash ./01_create_small_iso.sh ${API_EP} ${WEBSERVER}
	cd iso-utils; bash ./02_patch_small_iso.sh

remount:
	sudo podman run --net=host idracbootfromiso -r ${DEST_SERVER} -u ${BMC_USER} -p ${BMC_PASS} -i http://${WEBSERVER}/${ISO} -d

server_action:
	ipmitool -H ${DEST_SERVER} -U ${BMC_USER} -P ${BMC_PASS} -I lanplus power ${ACTION}

clear_jobs:
	sudo podman run --net=host --entrypoint="racadm -r ${DEST_SERVER} -u ${BMC_USER} -p ${BMC_PASS} jobqueue delete -i JID_CLEARALL_FORCE" idracbootfromiso                                                                                                                                                               

sleep:
	sleep 2

