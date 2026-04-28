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

### Check

2. Run following command to check if the computer has the `Secure Boot disabled` and the `Setup Mode enabled`.

    ```bash
    sbctl status
    ```

## Create and enroll PK, KEK, db keys in the UEFI

### Steps
1. Run the following command.
    ```bash
    sbctl create-keys
    ```
2. Run the following command (If you want to keep Microsoft's keys).
    ```bash
    sbctl enroll-keys --microsoft
    ```
3. Otherwise, run this command
    ```bash
    sbctl enroll-keys
    ```

## Move PK, KEK, db keys on a external USB

### Steps
1. Insert your external USB.
2. Check what is the path to the external USB using `lsblk`.
3. Run the following command.
    ```bash
    mv /var/lib/sbctl/keys/* /mnt/
    ```

## Create Unified Kernel Image

### Steps
1. Install `ukify` package.
    ```bash
    sudo apt install systemd-ukify
    ```
2. Insert your USB key containing your PK, KEK and db key pairs.
3. Check what is the path to it using `lsblk`.
4. Run following command to create a single .efi file which will be used for boot.

    ```bash
    ukify build \
    --linux=/boot/vmlinuz \
    --initrd=/boot/initrd.img \
    --cmdline='quiet rw' \
    --secureboot-private-key=/mnt/db/db.key \
    --secureboot-certificate=/mnt/db/db.pem \
    --os-release=@/etc/os-release \
    --output=/boot/efi/EFI/Linux/3052_uki.efi
    ```

## Bind LUKS with Tang Server and TPM module

### Steps
1. Make sure that the Tang server is findable by the client's computer.
2. Run the following script.
    ```bash
    sudo bash script.sh
    ```
3. Insert the LUKS2 passphrase if needed.

## Change Boot order

