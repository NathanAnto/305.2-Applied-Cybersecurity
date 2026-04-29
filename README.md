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

## Documentation

- [How it works](doc/HOW_IT_WORKS.md) — boot sequence, initramfs role, cryptographic protocol
- [Installation](doc/INSTALLATION.md) — Tang server setup, client configuration, binding steps
- [Limitations](doc/LIMITATIONS.md) — residual attack vectors and improvement paths

## Authors

| Name | GitHub |
|------|--------|
| Nathan Antonietti | [@NathanAnto](https://github.com/NathanAnto) |
| Vincent Cordola | [@VinceCor](https://github.com/VinceCor) |
| Ünal Külekçi | [@UnalKulekci](https://github.com/UnalKulekci) |
| Filip Siliwoniuk | [@fylis](https://github.com/fylis) |
| Kevin Voisin | [@kevivois](https://github.com/kevivois) |