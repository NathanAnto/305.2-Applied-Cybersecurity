# Breaking Full Disk Encryption (FDE)
In this document, we will demonstrate how to forensically extract the master key from a live system in order to decrypt a LUKS volume without the user passphrase.

## 1. Install a Linux VM with LUKS (Full Disk Encryption)
For this part, you need to install VirtualBox and Ubuntu Server.
- Install Ubuntu Server: https://ubuntu.com/download/server (18.04)
- Install Virtualbox: https://www.virtualbox.org/
Create new VM in Virtualbox:
- OS: Ubuntu Server or DEBIAN
- RAM: 2-4 GO

First, create your VM using VirtualBox

<img src="images/s1_1.png">

Specify virtual hardware and select "finish" when you're done 

<img src="images/s1_2.png">

During installation, enable Full Disk Encryption with LUKS.
- On Ubuntu Select "Set up this disk as an LVM group" and Encrypt the LVM group with LUKS

The installer automatically configures LUKS + AES on the entire disk.

<img src="images/s1_3.png">

## 2. Start VM and authenticate the user
1. Start VM, GRUB prompts fot the LUKS passphrase at boot time
2. Enter passphrase, the system decrypts and mounts the disk
3. At that precise moment, the AES master key is loaded into RAM.

## 3. Take a memory dump of the running VM
The goal is to capture the VM's RAM while it is running and the LUKS disk is mounted (meaning the master key is in memory). We work from the host machine, without touching the VM.

### 3.1 Check if vm is running and find out its exact name
1. Open external terminal
2. Go to the VirtualBox folder: 
```bash 
cd "C:\Program Files\Oracle\VirtualBox"

VBoxManage list runningvms

# You will get the name of your VM
# example:
"bfdee" {98839629-5a1e-430c-b99c-f45a8572989d}
```

### 3.2 Perform a memory dump
- ```bfdee```: The exact name of the VM
- ```\\wsl.localhost\Ubuntu\home\YourUser\memdump.elf```: The path where you want to save the dump
```bash
VBoxManage debugvm "bfdee" dumpvmcore --filename C:\forensics\memdump.elf
# Your file must be similar size as your VM's memory
```

## 4. Scan dump with aeskeyfind
Install aeskeyfind and then you can run the analysis right away.
```bash
aeskeyfind memdump.elf¨
# You will see
94c677a283fd76f0da9bdd3a36251a40
0b7e1b5ffebf527fc5066ac1832caa6f
Keyfind progress: 100%
```
To find out which key is the right one, we can try them in the next step.

## 5. Mount the encrypted disk on a new VM
For this part, we will use another Ubuntu VM. The goal now is to mount the LUKS volume on a separate analysis machine using the master key directly, without ever knowing the user passphrase.

### 5.1 Analytics VM
For this part, I'm using a standard Ubuntu installation. https://ubuntu.com/download/desktop
```bash
# tools required on the VM
sudo apt install -y cryptsetup aeskeyfind lvm2 xxd
```

### 5.2 Set up shared folder between Windows and VM 2
For this part, I need to retrieve the disk from the other VM. Here’s one way to do it using VirtualBox.
The goal is therefore to transfer the disk and convert the .vdi file into a RAW image.
1. On windows create a shared folder (for example: ```C:\forensics```)
2. In VirtualBox with VM 2 turned off
    - Click on your VM 2 -> Configuration -> Shared Folders
    - File path: ```C:\forensics```
    - Share name: ```forensics```
    - Check "Automatic Installation" and "Permanent Access"

<img src="images/s1_4.png">

4. Restart the VM and install the guest additions
    - ```sudo apt install virtualbox-guest-utils virtualbox-guest-additions-iso```
5. Add your user to the group vboxsf to see the shared folder
    - ```sudo adduser $USER vboxsf```
6. Restart and you should see ```/media/sf_forensics```

### 5.3 Convert .vdi file to a RAW image (from windows)
Before working on the disc, you need to convert it on your computer.
```bash
cd "C:\Program Files\Oracle\VirtualBox"

# VM is your Ubuntu Server
.\VBoxManage.exe clonehd "C:\Users\YourUser\VirtualBox VMs\VM\VM.vdi" "C:\forensics\disc.img" --format RAW
```

### 5.4 Copy the files to VM 2
It's better to work on local copies.
```bash
# Create work file
mkdir ~/analysis 
# Copy the files from the shared folder
cp /media/sf_forensics/disc.img ~/analysis/
# Check to see if the copy worked
ls -lh ~/analysis/
```

### 5.5 Identify LUKS partition
```bash
# See the partition table in the image
sudo fdisk -l disc.img
# Sample result
Device          Start      End      Sectors  Size  Type
disque.img1      2048      4095      2048     1M   BIOS boot
disque.img2      4096    2101247   2097152    1G   Linux filesystem
disque.img3   3805184   42917887  39112704 18.7G   Linux filesystem
```
Calculates the offset of the LUKS partition. It is always the largest one, usually the last one.
- For this example: 3805184 * 512 -> 1948254208

This number will be used in the next step

##### todo: doc details

### 5.6 Associate the partition with a loop device
```bash
# Find an available loop device
sudo losetup -f
# Create the loop device using the calculated offset (replace offset and loop device with yours)
sudo losetup -o 1948254208 /dev/loop0 ~/analysis/disc.img
# Verify that LUKS is detected
sudo cryptsetup luksDump /dev/loop0
```
<img src="images/s1_5.png">

### 5.7 Test each candidate key
For each key returned by aeskeyfind, we're going to combine them and test them.
```bash
# Define the candidate key
KEY1="94c677a283fd76f0da9bdd3a36251a40"
KEY2="0b7e1b5ffebf527fc5066ac1832caa6f"

# Converte the hexadecimal key to a binary file
echo -n "${KEY1}${KEY2}" | xxd -r -p > /tmp/masterkey.bin

# Attempt to open the LUKS volume using this master key
sudo cryptsetup luksOpen /dev/loop0 volume_recovered --master-key-file /tmp/masterkey.bin

# If that doesn't work, try the reverse order
echo -n "${KEY2}${KEY1}" | xxd -r -p > /tmp/masterkey.bin

# If there is no error message, the key is correct, if the key is incorrect, you will see: No key available with this passphrase.

```
From that point on, the disk that was locked with a passphrase will be available.
<img src="images/s1_6.png">



#### Sources
- Official documentation about FDE: https://documentation.ubuntu.com/security/security-features/storage/encryption-full-disk/
- Install Ubuntu with LUKS Encryption: https://gist.github.com/superjamie/d56d8bc3c9261ad603194726e3fef50f
- Memory dump: https://cylab.be/blog/99/dump-the-memory-of-a-virtualbox-vm-for-volatility3?accept-cookies=1
- Understanding AESKeyFind: https://www.siberoloji.com/aeskeyfind-kali-linux-advanced-memory-forensics-aes-key-recovery/
- cryptsetup: https://man7.org/linux/man-pages/man8/cryptsetup.8.html
- quick and dirty linux forensics: https://clo.ng/blog/quick_and_dirty_linux_forensics/
- Cracking LUKS/dm-crypt passphrases: https://diverto.github.io/2019/11/18/Cracking-LUKS-passphrases
- The keys returned by aeskeyfind are 32 bytes (256 bits) long, but LUKS 2 can use a 512-bit key in XTS mode. In AES-XTS mode, the key is actually two concatenated 256-bit keys: one for encryption and one for tweaking. https://crossbowerbt.github.io/xts_mode_tweaking.html
