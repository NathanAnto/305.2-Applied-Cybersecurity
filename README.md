# Full-Disk Encryption MVP — Network Unlock + TPM 2.0

**Course**: 305.2 - Applied Cybersecurity

## Description

This project implements a **full-disk encryption (FDE)** MVP based on a two-factor simultaneous chain of trust.
The root disk of an Ubuntu client is encrypted with **LUKS2** and unlocks automatically at boot only if two conditions are met at the same time:

- **TPM 2.0** validates the integrity of the boot chain (BIOS, kernel, initramfs)
- **Tang server** (acting as a network KMS) is reachable and responds correctly

Both shares are combined via **Shamir's Secret Sharing** (Clevis SSS pin) to reconstruct the LUKS2 passphrase. If either factor is missing or tampered with, the disk stays locked.

> The McCallum-Relyea protocol (ECDH variant) ensures the client never reveals its secret to the Tang server.

## Stack

| Component | Role |
|-----------|------|
| **Tang** (Fedora / Docker) | Network Key Management Server |
| **Clevis + pin SSS** | Secret reconstruction via Shamir's Secret Sharing |
| **TPM 2.0** | Boot chain integrity measurement |
| **LUKS2** | Root disk encryption |
| **Custom initramfs** | Early-boot network + unlock toolchain |
| **BitLocker + UKI** | Alternative FDE via Unified Kernel Image (no initramfs modification) |

## Documentation

### Core
 
| Document | Description |
| --- | --- |
| [Installation](doc/INSTALLATION.md) | Tang server setup, client configuration |
| [Limitations and Improvements](doc/LIMITATIONS_IMPROVEMENTS.md) | Residual attack vectors and improvement paths |
| [Contributing](doc/CONTRIBUTING.md) | Guidelines for contributing to this project |
 
### Technical Deep Dives
 
| Document | Description |
| --- | --- |
| [Linux Booting](doc/linux-booting/linux-booting.md) | Boot sequence overview and key stages |
| [initramfs](doc/initramfs-doc/initramfs.md) | Role of initramfs in the early-boot unlock chain |
| [LUKS Encryption + TPM](doc/luks/luks-encryption-with-tpm-me.md) | LUKS2 internals and TPM binding |
| [LUKS Encryption](doc/luks_encryption/luks_encryption.md) | LUKS encryption concepts and setup |
| [Breaking Full Disk Encryption](doc/bfde/breaking_full_disk.md) | Known attack scenarios against FDE |
| [Secure Boot](doc/secure-boot/Secure-Boot.md) | Secure Boot overview and trust chain |
| [Secure Boot Tutorial](doc/secure-boot/Secure-Boot_tutorial.md) | Step-by-step Secure Boot configuration |
| [BitLocker](doc/bitlocker/bitlocker.md) | BitLocker overview and comparison |
| [BitLocker Encryption](doc/bitlocker/bitlocker_encryption.md) | BitLocker encryption internals (XTS-AES, CBC) |
 
### Archive
 
| Document | Description |
| --- | --- |
| [Architecture Overview](doc/archive/security-architecture/architecture.md) | Early-stage system architecture notes |
| [Security Architecture MVP](doc/archive/security-architecture/security_architecture_mvp.md) | Initial MVP security architecture design |



## Contributors

- [Nathan Antonietti](https://github.com/NathanAnto)
- [Vincent Cordola](https://github.com/VinceCor)
- [Ünal Külekçi](https://github.com/UnalKulekci)
- [Filip Siliwoniuk](https://github.com/fylis)
- [Kevin Voisin](https://github.com/kevivois)