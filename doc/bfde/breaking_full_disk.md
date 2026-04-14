# Breaking Full Disk Encryption (FDE)
In this document, we will demonstrate how to forensically extract the master key from a live system in order to decrypt a LUKS volume without the user passphrase.

## 1. Install a Linux VM with LUKS (Full Disk Encryption)
For this part, you need to install VirtualBox and Ubuntu Server.
- Install Ubuntu Server: https://ubuntu.com/download/server
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
VBoxManage debugvm "bfdee" dumpvmcore --filename \\wsl.localhost\Ubuntu\home\YourUser\memdump.elf
# Your file must be similar size as your VM's memory
```

#### Sources
- Official documentation about FDE: https://documentation.ubuntu.com/security/security-features/storage/encryption-full-disk/
- Install Ubuntu with LUKS Encryption: https://gist.github.com/superjamie/d56d8bc3c9261ad603194726e3fef50f
- Memory dump: https://cylab.be/blog/99/dump-the-memory-of-a-virtualbox-vm-for-volatility3?accept-cookies=1

