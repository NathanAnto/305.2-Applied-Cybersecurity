# Enable Secure Boot with UKI signature
To enable the Secure Boot with signed Unified Kernel Image, we have used an open source solution, called `sbctl`, which simplifies the creations of keys, enrolling them into the UEFI, etc.

## Install sbctl
sbctl is the package used to enroll our PK, KEK and db keys in the UEFI firmware.

### Steps
1. Enter this [page](https://software.opensuse.org/download/package?package=sbctl&project=home%3Ajloeser%3Asecureboot).
2. Click on Ubuntu.
3. Click on `Grab binary packages directly`.
4. Download the `sbctl_x.yz-21.1_amd64.deb` package.
5. Install the package using following command.
```bash
sudo apt install ./sbctl_x.yz-21.1_amd64.deb
```

## Change Secure Boot to Setup Mode
To enable new key enrolling, the computer's Secure Boot settings has to be changed.

### Steps
1. Enter UEFI on laptop.
2. In `Security` section, click on `Reset to Setup Mode` and click `Yes`.
3. Click on F10 to `Save and Exit` settings.

> ⚠️ This step will delete all your OEM keys. Be sure to make a copy of them if needed.

### Check
Run following command to check if the computer has the `Secure Boot disabled` and the `Setup Mode enabled`.
```bash
sbctl status
```

## Add execution rights to all scripts from MVP/scripts
Our repository contains scripts that will facilitate the UKI creation, adding the UKI image as a bootable as well as binding Tang server using Clevis.

### Steps
Give an execution right on all scripts contained in `305.2-Applied-Cybersecurity/MVP/scripts` directory.
```bash
sudo chmod +x 305.2-Applied-Cybersecurity/MVP/scripts/*.sh
```

## Enroll PK, KEK, db keys in the UEFI
Before enrolling, be sure that you have your own PK, KEK and db key pair, they could be created via `openssl` or `sbctl` for simplification.

### Steps
Run the following script from `305.2-Applied-Cybersecurity/MVP/scripts` folder to enroll your keys.
```bash
cd 305.2-Applied-Cybersecurity/MVP/scripts
sudo bash enroll-keys.sh
```
> The script copies keys from `/mnt/keys` to `/var/lib/sbctl/keys`, if you do not have PK, KEK and db keys on a USB stick which is mounted, be sure to have them in `/var/lib/sbctl/keys` folder as follows:

```bash
tree /mnt/keys

├── db
│   ├── db.key
│   └── db.pem
├── KEK
│   ├── KEK.key
│   └── KEK.pem
└── PK
    ├── PK.key
    └── PK.pem
```

## Create Unified Kernel Image
To ensure, that only our Kernel and initramfs is booted, we need to create an UKI which contains those and it is signed with our keys.

It avoids that initramfs or Kernel is tampered. If it is the case, the computer won't boot in the .efi.

### Steps
1. Install `ukify` package.
```bash
sudo apt install systemd-ukify
```
2. Insert your USB key containing your PK, KEK and db key pairs.
3. Mount the USB key if needed, for example `/mntX`.
4. Run the following script to create a single .efi file which will be used for boot.
```bash
cd 305.2-Applied-Cybersecurity/MVP/scripts
sudo bash ukify.sh
```

## Add the Unified Kernel Image in the boot order

### Steps
1. Run the following script to sign the UKI.
```bash
cd 305.2-Applied-Cybersecurity/MVP/scripts
sudo bash add_boot.sh
```
2. Delete other boot options which has `.efi` ending. 
```bash
sudo efibootmgr -b XXXX -B
```

> Do not delete `305.2 Boot image` which has the `\EFI\Linux\3052_uki.efi` path. 

## Changing boot order
The computer should boot on our Unified Kernel Image `3052_uki.efi`. To do that follow those steps.

### Steps
1. Check all boot possibilities with `efibootmgr`.
```bash
sudo efibootmgr
```
2. Check `BootOrder`, the `3052_uki.efi` should be the first one.
3. If it is not the case, enter the following command to change the boot order.
```bash
sudo efibootmgr -o XXXX,XXXY,XXXZ
```
> `XXXX` is the boot order for our `.efi` path.

## Activate Secure Boot

### Steps
1. Enter UEFI in the laptop (Power ON + click on F2).
2. In `Security` section, click on `Secure Boot` and choose `Enabled`.
3. Click on F10 to `Save and Exit` settings.

## Bind LUKS with Tang Server and TPM module

### Steps
1. Make sure that the Tang server is findable by the client's computer.
2. Run the following script.
```bash
cd 305.2-Applied-Cybersecurity/MVP/scripts
sudo bash install.sh
```
3. Insert the LUKS2 passphrase if needed.
4. Recreate an UKI and resign it. Follow [Create Unified Kernel Image, step 4](#create-unified-kernel-image).

## Sources
- [Ukify](https://www.freedesktop.org/software/systemd/man/latest/ukify.html)
- [sbctl](https://github.com/foxboron/sbctl)
- [Gemini](https://gemini.google.com/), used to debug with the UKI creation, exactly for `--cmdline` with LUKS UUIDs.