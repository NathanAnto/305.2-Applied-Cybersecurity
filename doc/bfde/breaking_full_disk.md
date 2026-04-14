# Breaking Full Disk Encryption (FDE)
In this document, we will demonstrate how to forensically extract the master key from a live system in order to decrypt a LUKS volume without the user passphrase.

## 1. Install a Linux VM with LUKS (Full Disk Encryption)
For this part, you need to install VirtualBox and Ubuntu Server.
- Install Ubuntu Server: https://ubuntu.com/download/server
- Install Virtualbox: https://www.virtualbox.org/
#### 1.1 Install Linux VM with LUKS encryption
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


#### Sources
- Official documentation about FDE: https://documentation.ubuntu.com/security/security-features/storage/encryption-full-disk/
- Install Ubuntu with LUKS Encryption: https://gist.github.com/superjamie/d56d8bc3c9261ad603194726e3fef50f

