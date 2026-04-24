# LUKS FDE on a USB

To understand how LUKS encrypts an entire disk using a passphrase, I created a small tutorial on how to do it. This shows the simple commands used to encrypt and decrypt a USB key on a linux machine.

First, after plugging in our USB, we can list the available partitions using `lsblk`:

```sh
lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda      8:0    0 476.9G  0 disk
├─sda1   8:1    0   300M  0 part /boot/efi
├─sda2   8:2    0 459.6G  0 part /var/tmp
│                                /var/cache
│                                /var/log
│                                /srv
│                                /root
│                                /home
│                                /
└─sda3   8:3    0  17.1G  0 part [SWAP]
sdb      8:16   1   1.9G  0 disk
└─sdb1   8:17   1   1.9G  0 part # USB Stick
zram0  253:0    0  31.2G  0 disk [SWAP]
```

To start the encryption, we need to use the `cryptsetup` command. First, we'll start by formatting our USB partition using that command:

```sh
sudo cryptsetup luksFormat -v /dev/sdb1
```

> [!WARNING]
> This will erase all data found on the drive !

It will then ask you to enter a passphrase for the encryption.

Then we want to "open" our drive. This reads the LUKS header and asks for a password:

```sh
sudo cryptsetup open -v /dev/sdb1 my_usb
```
> [!INFO]
> You can see information about the header using `cryptsetup luksDump /dev/sdX`.

The kernel then creates a new virtual block device at `/dev/mapper/my_usb`. We can then make a filesystem on that block:
```sh
sudo mkfs.ext4 /dev/mapper/my_usb
```

And then mount (`/mnt/usb` folder needs to be created before):
```sh
sudo mount /dev/mapper/my_usb /mnt/usb
```

We can now put some files into the USB:

```sh
$ sudo chown $(whoami):$(whoami) /mnt/usb
$ cd /mnt/usb
$ echo "SECRET INFORMATION" > secret.txt
$ ls
lost+found  secret.txt
$ cat secret.txt
SECRET INFORMATION
```

Unmount:

```sh
sudo umount /mnt/usb
sudo cryptsetup close my_usb
```

Now, anytime you want to mount your usb stick, you should enter your passphrase when prompted. The exact `cryptsetup` output may vary depending on your system and configuration:

```sh
$ sudo cryptsetup open /dev/sdb1 my_usb
Enter passphrase for /dev/sdb1:
Key slot 0 unlocked.
Command successful.
$ sudo mount /dev/mapper/my_usb /mnt/usb
```

## Source

[Encrypt an external disk or USB stick with LUKS](https://gist.github.com/JChristensen/02f97ee2acfb22fa48678853a424c890)