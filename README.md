# 305.2 - Applied Cybersecurity
**Full-disk encryption MVP with network unlock + TPM 2.0**

Network-Bound Disk Encryption, Tang "KMS", Clevis, LUKS2, TPM2

# Overview
This project implements a full-disk encryption (FDE) MVP based on a two-factor simultaneous chain of trust.

| Component | Role |
|-----------|------|
| **Tang server** (Fedora / Docker) | Key Management Server, responds to customers' ECDH inquiries |
| **Ubuntu client** | Root disk encrypted with **LUKS2**, automatic unlocking at startup |
| **Clevis + pin SSS** | Orchestrates the secret shared between Tang and TPM2 using Shamir's Secret Sharing |
| **TPM2** | Checks the integrity of the boot chain |
| **Custom initramfs** | Include the network scripts and Clevis required for unlocking before mounting the root partition |

Unlocking is only possible if both conditions are met at the same time.
> The McCallum-Relyea protocol (ECDH variant) ensures that the client never reveals its secret to the Tang server 

## How does unlocking work?
During boot, the initramfs executes the following sequence:
1. Kernel loads and decompresses initramfs into memory
2. init-top        : Starting udev, initializing userspace
3. init-premount   : Loading kernel modules (network, TPM)
4. local-premount  : Network initialization (DHCP/static)
5. local-top       : Clevis reads the LUKS2 token, contacts Tang + queries TPM2,
                     reconstructs the secret (SSS), cryptsetup open /dev/*
6. switch_root     : Root filesystem mounted, handoff to systemd (PID 1)

## Role of the initramfs
The initramfs (initial RAM filesystem) is a temporary filesystem loaded into memory by the kernel before the actual root filesystem becomes available. In this project, it has been customized to include the tools needed for LUKS2 decryption.

## Prerequisites

### Tang Server
- Docker
- Port **7500** reachable from the client LAN

### Client
- Root disk already encrpted with **LUKS2**
- Wired **network interface** available
- **TPM 2.0** present and accessible
- LAN access to the Tang server (port 7500)
- Required packages: `cryptsetup`, `clevis`, `clevis-luks`, `clevis-tpm2`, `clevis-initramfs`, `tpm2-tools`


## Installation

### 1. Tang server (Docker)
Build and start the container:

```sh
# Build the image
docker build -t tang_server -f Dockerfile.tang .
# Run the container (with a persistent volume for keys)
docker run -d --name tang-server \
  -p 7500:7500 \
  -v tang-keys:/var/db/tang \
  tang_server
```
> Keys are generated automatically on first startup and persisted in the `tang-keys` volume.

### 2. Ubuntu client

#### 2.1 Adapt the configuration script
Before running the script, open `script.sh` and update the following variables to match your environment:
```bash
TARGET_DEV="/dev/nvme0n1p3"         # LUKS2 partition to unlock
TANG_URL="http://192.168.10.6:7500"  # Tang server IP and port
IP_ADDR="192.168.10.2"              # Client static IP used in initramfs
NETMASK="255.255.255.0"
GATEWAY="192.168.10.1"
```

#### 2.2 Run the installation script
```sh
sudo bash script.sh
```
The script performs the following steps:
1. Installs the required packages
2. Installs the network hook into initramfs (`/etc/initramfs-tools/hooks/clevis-network`)
3. Configures a static IP for the initramfs phase (`/etc/initramfs-tools/conf.d/static_ip`)
4. Prompts to perform the Clevis binding (TPM2 + Tang via SSS)
5. Regenerates the initramfs (`update-initramfs -u -k all`)


## Contributors
- [Nathan Antonietti](https://github.com/NathanAnto)
- [Vincent Cordola](https://github.com/VinceCor)
- [Ünal Külekçi](https://github.com/UnalKulekci)
- [Filip Siliwoniuk](https://github.com/fylis)
- [Kevin Voisin](https://github.com/kevivois)
