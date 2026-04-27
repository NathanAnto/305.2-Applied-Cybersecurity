# 305.2 - Applied Cybersecurity
**Full-disk encryption MVP with network unlock + TPM 2.0**

Network-Bound Disk Encryption, Tang 'KMS', Clevis, LUKS2, TPM2

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

## Contributors
- [Nathan Antonietti](https://github.com/NathanAnto)
- [Vincent Cordola](https://github.com/VinceCor)
- [Ünal Külekçi](https://github.com/UnalKulekci)
- [Filip Siliwoniuk](https://github.com/fylis)
- [Kevin Voisin](https://github.com/kevivois)
