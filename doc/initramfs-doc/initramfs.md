# **Initramfs - Researches**
***By Kevin Voisin - 305.2 : Cybersecurity***

The initramfs (initial RAM filesystem) is a temporary root filesystem that the Linux kernel mounts during early boot before the real root filesystem becomes available. Understanding and configuring it is essential when you need custom drivers at boot time, encrypted root filesystems, or specialized boot sequences.

When the kernel boots, it needs certain drivers and tools available before it can mount the actual root filesystem. The initramfs handles this:

1. Kernel loads and decompresses initramfs into memory
2. Kernel mounts initramfs as a temporary root filesystem
3. Init scripts in initramfs load necessary drivers (storage controllers, RAID, LVM, encryption)
4. The real root filesystem gets mounted
5. Control transfers from initramfs to the real system's init (systemd)

# Customization of a initramfs on Ubuntu

## Hooks Scripts


These are used when an initramfs image is created and not included in the image itself. They can however cause files to be included in the image. Hook scripts are executed under errexit. Thus a hook script can abort the mkinitramfs build on possible errors (exitcode != 0).

Their purposes is to :
    - Copy binaries (curl,cryptsetup,etc)
    - add files such as certificats,configs
    - include modules in the kernel


They can be found in two places: /usr/share/initramfs-tools/hooks and /etc/initramfs-tools/hooks.
You can see more about [here](https://manpages.ubuntu.com/manpages/jammy/man7/initramfs-tools.7.html#hook-scripts)


## Boot Scripts

These are included in the initramfs image and normally executed during kernel boot in the early user-space before the root partition has been mounted.
Their purposes is to:
    - execute some code
    - Call a KMS/Server (Hashicorp,openBAO,Tang)
    - decrypt your disk
They can be found in two places /usr/share/initramfs-tools/scripts/ and /etc/initramfs-tools/scripts.

They are separated in 7 folders :
- **init-top**:  
These scripts are executed at the very beginning of initramfs  
They run right after `/proc` and `/sys` are mounted  
They are used to initialize the early userspace environment  'donc i
for example starting **udev** to populate `/dev`

*note : **udev** is the system that handles peripherals on ubuntu*

---

- **init-premount**:  
These scripts are executed after kernel modules are loaded  
They are used to prepare the system before accessing the root device  
for example loading extra drivers or preparing early networking  

---

- **local-top**:  
These scripts are executed before the root device is available  
They are used to prepare access to local storage  
for example unlocking encrypted disks (`cryptroot`)  

---

- **local-block**:  
These scripts are executed repeatedly for block devices  
They are used to ensure required device nodes exist  
for example waiting for a disk to appear or retrying detection  

---

- **local-premount**:  
These scripts are executed just before mounting the root filesystem  
They are used to finalize access to the root device  
for example connecting to WiFi, calling an API or KMS to retrieve a key,  
and unlocking/decrypting the filesystem with this key 

---

- **local-bottom**:  
These scripts are executed right after the root filesystem is mounted  
They are used for final adjustments before switching to the real system  
for example cleaning temporary setup or preparing the environment  

---

- **init-bottom**:  
These scripts are executed at the very end of initramfs  
They run just before switching to the real root filesystem  
They are used to stop early services (like **udev**)  
and finalize the transition to the main OS  


You can see more about [here](https://manpages.ubuntu.com/manpages/jammy/man7/initramfs-tools.7.html#boot-scripts) and [here](https://www.ullright.org/ullWiki/show/initramfs-tools)


## Configuration files
They are non-executable *.conf* file,read by scripts during initramfs execution, used to store settings,credentials or parameters

### What do they contains
1. *Network configuration*: SSID,password,auth method
2. *Cryptographic configuration*: encrpytion parameters,LUKS device mapping info
3. *TLS / OpenBao configuration*: CA certificates,server URL

You can see more [here](https://manpages.ubuntu.com/manpages/trusty/man5/initramfs.conf.5.html)

## Modules
They are device drivers which may be loaded into the running kernel to extend its functionality

For example :
- *Network modules*: used to detect wifi card,enable network interface
- *Storage modules*: used to detect disks,access LUKS encrypted partitions

You can see more about [here](https://kernel-team.pages.debian.net/kernel-handbook/ch-modules.html) and [here](https://wiki.archlinux.org/title/Kernel_module)


<!---
## Setup Clevis+Tang LUKS encryption

***We assume here that the computer is already LUKS encrypted from the os installation configuration.***

The [script.sh](../../scripts/CLEVIS-LUKS/script.sh) file is the startpoint.

It modify and update the initramfs and add the script [clevis-network](../../scripts/CLEVIS-LUKS/clevis-network.sh) in the correct directory of the initramfs, this script will setup the necessary network libraries so that the initramfs can access the TANG server which is used for the handshake with clevis.


Also,The [script.sh](../../scripts/CLEVIS-LUKS/script.sh) file handles the static IP configuration.
It also install the required libraires and setup clevis binding with the TANG sever

Then we make the initramfs persistent by using `
update-initramfs -u -k all` in the terminal

The [clean.sh](../../scripts/CLEVIS-LUKS/clean.sh) is used to clean the custom files in the initramfs , don't forget to unbind the tang-server from clevis (if necessary)

-->
## Does a OS Update overwrite custom initramfs modification ?

The files that are manually placed in /etc/initramfs-tools are preserved across OS updates. When the initramfs is rebuilt (e.g., after an update), these files such as the scripts and hooks used in our solution, are automatically included again, so this is not an issue.

We use certain PCRs (PCR 7) for Clevis + Tang verification to determine whether decryption is allowed. However, after a system update, some PCR values may change, which can prevent Clevis from successfully decrypting the disk.

Therefore, we may need to disable or carefully manage updates that affect Secure Boot and PCR values on the client machine.

## Sources

- [initramfs-tools man page](https://manpages.ubuntu.com/manpages/jammy/man7/initramfs-tools.7.html)
- [How to configure initramfs on ubuntu](https://oneuptime.com/blog/post/2026-03-02-how-to-configure-initramfs-on-ubuntu/view)
- [initramfs.conf](https://manpages.ubuntu.com/manpages/trusty/man5/initramfs.conf.5.html)