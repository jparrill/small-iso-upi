#!/bin/bash
firstboot_args='console=tty0 rd.neednet=1'
for vg in $(vgs -o name --noheadings) ; do vgremove -y $vg ; done
for pv in $(pvs -o name --noheadings) ; do pvremove -y $pv ; done

if [ -f /tmp/installation_disk ]; then
  install_device_file=$(cat /tmp/installation_disk)
  install_device="/dev/${install_device_file}"
  if [ ! -b ${install_device} ]; then
    echo "Can't find device ${install_device}, trying to guess install device now"
    exit 1
  fi
elif [ -b /dev/vda ]; then
  install_device='/dev/vda'
elif [ -b /dev/sda ] && [ "$(lsblk /dev/sda)" != "" ] ; then
  install_device='/dev/sda'
elif [ -b /dev/sdb ] && [ "$(lsblk /dev/sdb)" != "" ] ; then
  install_device='/dev/sdb'
elif [ -b /dev/sdc ] && [ "$(lsblk /dev/sdc)" != "" ] ; then
  install_device='/dev/sdc'
elif [ -b /dev/sdd ] && [ "$(lsblk /dev/sdd)" != "" ] ; then
  install_device='/dev/sdd'
elif [ -b /dev/nvme0 ]; then
  install_device='/dev/nvme0'
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
