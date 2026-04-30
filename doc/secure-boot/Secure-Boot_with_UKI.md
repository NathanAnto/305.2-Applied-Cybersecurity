# Enable Secure Boot with UKI signature
To enable the Secure Boot with signed Unified Kernel Image, we have used an open source solution, called `sbctl`, which simplifies the creations of keys, enrolling them into the UEFI, etc.

## Install sbctl

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

### Steps
1. Enter UEFI in the laptop (Power ON + click on F2).
2. In `Security` section, click on `Reset to Setup Mode` and click `Yes`.
3. Click on F10 to `Save and Exit` settings.

> ⚠️ This step will delete all your OEM keys. Be sure to make a copy of them if needed.

### Check

2. Run following command to check if the computer has the `Secure Boot disabled` and the `Setup Mode enabled`.
    ```bash
    sbctl status
    ```

## Enroll PK, KEK, db keys in the UEFI
Before enrolling, be sure that you have your own PK, KEK and db key pair, they could be created via `openssl` or `sbctl` for simplification.

### Steps
1. Run the following script to enroll our keys.
    ```bash
    sudo bash enroll.keys.sh
    ```

## Create Unified Kernel Image

### Steps
1. Install `ukify` package.
    ```bash
    sudo apt install systemd-ukify
    ```
2. Insert your USB key containing your PK, KEK and db key pairs.
3. Mount the USB key if needed, for example `/mntX`.
4. Run the following script to create a single .efi file which will be used for boot.
    ```bash
    sudo ./ukify.sh
    ```

## Add the Unified Kernel Image in the boot order

### Steps
1. Run the following script to sign the UKI.
    ```bash
    sudo ./add_boot.sh
    ```
2. Delete other boot options. 
    ```bash
    sudo efibootmgr -b XXXX -B
    ```

> `XXXX` is the boot order ID which were not be used, for example, `shimx64.efi`, etc.

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
    sudo bash script.sh
    ```
3. Insert the LUKS2 passphrase if needed.
4. Recreate an UKI and resign it. Follow [Create Unified Kernel Image](#create-unified-kernel-image) and [Add the Unified Kernel Image in the boot order
](#add-the-unified-kernel-image-in-the-boot-order).

> Ensure to delete old .efi with `efibootmgr` to avoid confusion.