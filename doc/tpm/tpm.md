## What is TPM?

A **Trusted Platform Module (TPM)** is a secure cryptoprocessor that implements the [ISO/IEC 11889](https://www.iso.org/standard/66510.html) standard — a dedicated microprocessor designed to secure hardware by integrating cryptographic keys into devices. The chip includes multiple physical security mechanisms to make it tamper-resistant, and malicious software is unable to tamper with its security functions. In practice a TPM can be used for various security applications such as:

- **Cryptographic key management** — generate, store, and limit the use of cryptographic keys. Keys are created inside the TPM's own processor and held in shielded memory that the host cannot read; signing and encryption can happen without the key ever leaving the chip.
- **Device authentication** — authenticate a device by using the TPM's unique Endorsement Key (EK), an asymmetric key pair (RSA or ECC) provisioned into non-volatile memory at manufacturing time. This key acts as the device's fingerprint, proving "this is a real and specific device."
- **Platform integrity** — ensure platform integrity by taking and storing security measurements of the boot process (secure boot). At each stage (firmware → bootloader → kernel), the next stage is hashed and `Extend`ed into a PCR register inside the TPM; any change anywhere in the chain shifts the PCR value and can be detected.
- **Disk encryption** — store disk encryption keys so they are only released when the system is in a trusted state. The TPM seals an encryption key against expected PCR values; at unseal time, if the PCRs still match, the key is released — otherwise the TPM refuses. This is how TPM-backed LUKS auto-unlock works.
- **Random number generation** — provide a hardware source of entropy for cryptographic operations. The TPM contains a physical noise generator that produces true randomness, unlike software-based PRNGs which are ultimately deterministic.




## Source

- [ArcLinux] https://wiki.archlinux.org/title/Trusted_Platform_Module
- [wikipedia] https://en.wikipedia.org/wiki/
