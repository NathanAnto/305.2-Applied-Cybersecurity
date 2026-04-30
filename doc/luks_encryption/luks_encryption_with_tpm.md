# LUKS Encryption with the TPM

## Identify Partition
First, you need to know which encrypted device you are "enrolling." You can find this by running:

```sh
lsblk -f
```
Look for the partition labeled crypto_LUKS. Let's assume it is /dev/sdx1.

If you want to encrypt data that isn't in a LUKS format, you use `cryptsetup reencrypt`. LUKS needs space (usually 16MB–32MB) at the start of the partition for its metadata (header).

You must shrink the existing filesystem slightly first, or use the `--reduce-device-size` flag if the filesystem supports it.

The Provisioning Command:
```sh
# This converts a plain filesystem to LUKS2 in-place
cryptsetup reencrypt --encrypt --type luks2 --reduce-device-size 32M /dev/sdx1
```

## The TPM Enrollment

We can bind our LUKS encrypted device to our current TPM state by using the `systemd-cryptenroll` command:

```sh
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/sdx
```

Here we defined PCR 7 as the only check, meaning that upon opening the partition, the kernel the secure boot state with the state of the secure boot when it was encrypted. If it is the same, the tpm decrypts the decryption key with it's master key.

To check the current PCR states, run:
```sh
systemd-analyze pcrs
```

## Automated Decryption

Once the device is enrolled and encrypted, it now needs on the fly decryption. This can be configured in the `/etc/crypttab` file:

```sh
# <name>       <device>      <password>    <options>
my_encrypted_disk  UUID=xxx-yyy  none          tpm2-device=auto
```

Then, to mount the partition, we modify the `/etc/fstab` file. This file is a list of all partitions to mount on boot:

```sh
UUID=xxx-yyy /mnt/usb	ext4	defaults,nofail,x-systemd.device-timeout=5s 0 2
```


And don't forget to update the initramfs.

```sh
sudo update-initramfs -u
```
or
```sh
sudo dracut -f
```
or
```sh
sudo mkinitcpio -P
```

