INITRAMFS="/etc/initramfs-tools"

rm  -f "${INITRAMFS}/hooks/clevis-network"

rm  -f "${INITRAMFS}/conf.d/static_ip"