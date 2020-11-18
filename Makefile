DEST_SERVER ?= 10.19.0.88
ACTION ?= off
GW ?= 2620:52:0:1304::1
USER ?= aW3s0m3U53R 
PASS ?= aW3s0m3P4SS 

default: recreate

all: recreate sleep server_action sleep remount

recreate:
	bash ./01_create_small_iso.sh api.mgmt-hub.e2e.bos.redhat.com ${GW}
	cd iso-utils; bash ./02_patch_small_iso.sh

remount:
	sudo podman run --net=host idracbootfromiso -r ${DEST_SERVER} -u ${USER} -p ${PASS} -i http://10.19.4.197/worker-small.iso -d

server_action:
	ipmitool -H ${DEST_SERVER} -U ${USER} -P ${PASS} -I lanplus power ${ACTION}

clear_jobs:
	sudo podman run --net=host --entrypoint="racadm -r ${DEST_SERVER} -u ${USER} -p ${PASS} jobqueue delete -i JID_CLEARALL_FORCE" idracbootfromiso

sleep:
	sleep 2
