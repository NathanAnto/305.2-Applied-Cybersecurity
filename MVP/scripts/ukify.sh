#!/bin/bash
set -e

LUKS_UUID=$(bash crypto_luks_uuid.sh)
ROOT_UUID=$(bash root_uuid.sh)

if [[ -z "$LUKS_UUID" || -z "$ROOT_UUID" ]] then
	echo "ERROR : LUKS_UUID or ROOT_UUID is empty"
	exit 1
fi

CMDLINE="quiet rw root=UUID=${ROOT_UUID} rd.luks.uuid=${LUKS_UUID} rd.luks.name=${LUKS_UUID}=dm_crypt-0"

echo "Cmdline = ${CMDLINE}"

sudo cp -r /mnt/keys/ /var/lib/sbctl/

sudo ukify build \
 --linux=/boot/vmlinuz-$(uname -r) \
 --initrd=/boot/initrd.img-$(uname -r) \
 --cmdline="${CMDLINE}" \
 --sign-kernel \
 --secureboot-private-key=/var/lib/sbctl/keys/db/db.key \
 --secureboot-certificate=/var/lib/sbctl/keys/db/db.pem \
 --os-release=@/etc/os-release \
 --output=/boot/efi/EFI/Linux/3052_uki.efi

sudo rm -rf /var/lib/sbctl/keys
