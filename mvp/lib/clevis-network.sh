#!/bin/sh
PREREQ=""
prereqs() { echo "$PREREQ"; }
case $1 in prereqs) prereqs; exit 0;; esac

. /usr/share/initramfs-tools/hook-functions

copy_exec /bin/ip /bin
copy_exec /usr/bin/clevis /usr/bin
copy_exec /usr/bin/clevis-decrypt-tang /usr/bin
copy_modules_dir kernel/drivers/net/ethernet