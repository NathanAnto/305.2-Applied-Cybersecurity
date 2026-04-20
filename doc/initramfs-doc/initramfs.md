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
    - Call a KMS (Hashicorp,openBAO,Tang)
    - decrypt your disk
They can be found in two places /usr/share/initramfs-tools/scripts/ and /etc/initramfs-tools/scripts.

They are separated in 3 folders :
- **local-top**:
These scripts are executed instantly after the start of initramfs
They are used to loads specific models, low-level
for example to setup minimal hardware
- **local-premount**:
These scripts are executed just before the mount of the root filesystem
They are used to connect to the wifi
call an API or an KMS securly/to get a decryption key
to unlock / decrypt filesystem
- **local-bootm**:
These scripts are exectued after the mount of the roof filesystem, just before the transition to the real OS
They are used to cleanup temporary files,disable network if needed,final security check before the handover to the OS


You can see more about [here](https://manpages.ubuntu.com/manpages/jammy/man7/initramfs-tools.7.html#boot-scripts)


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
- *Storate modules*: used to detect disks,access LUKS encrypted partitions

You can see more about [here](https://kernel-team.pages.debian.net/kernel-handbook/ch-modules.html) and [here](https://wiki.archlinux.org/title/Kernel_module)



## Tutorials & Commands
First you need to install the required packages to update / modify initramfs :

```bash
sudo apt update
sudo apt install initramfs-tools cryptsetup curl jq wpasupplicant
```

*initramfs-tools* : Package used to modify/customize our initramfs in a secure way
*cryptsetup*: Package used for disk encryption/decryption
*curl*: Package used to call an API (f.e retrieving KMS key)
*jq*: a command-line tool Package to parse,filter,and extract data from JSON
*wpasupplicant*: a low-level WIFI authentification daemon Package

### Adding required tools

Create a file named `base-tools` in the folder `/etc/initramfs-tools/hooks/`
These file will contains the packages fetching for the WIFI,KMS key retrieving,









## Does a Ubuntu OS Update overwrite custom initramfs ?


## Sources

- [initramfs-tools man page](https://manpages.ubuntu.com/manpages/jammy/man7/initramfs-tools.7.html)
- [How to configure initramfs on ubuntu](https://oneuptime.com/blog/post/2026-03-02-how-to-configure-initramfs-on-ubuntu/view)
- [initramfs.conf](https://manpages.ubuntu.com/manpages/trusty/man5/initramfs.conf.5.html)