#!/bin/bash
firstboot_args='console=tty0 rd.neednet=1'
for vg in $(vgs -o name --noheadings) ; do vgremove -y $vg ; done
for pv in $(pvs -o name --noheadings) ; do pvremove -y $pv ; done

install_device=$(cat /tmp/installation_disk)

if [ -b /dev/${install_device} ]; then
  install_device="/dev/${install_device}"
else
  echo "Can't find appropriate device to install to"
  exit 1
fi

cmd="coreos-installer install --firstboot-args=\"${firstboot_args}\" --ignition=/root/config.ign ${install_device} --copy-network"
bash -c "$cmd"
if [ "$?" == "0" ] ; then
  echo "Install Succeeded!"
  reboot
else
  echo "Install Failed!"
  exit 1
fi
