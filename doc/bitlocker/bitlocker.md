# Bitlocker
***By Filip Siliwoniuk - 305.2 : Cybersecurity***

BitLocker is a full disk encryption feature included with Microsoft Windows since Windows Vista. It is designed to protect data by providing encryption for entire volumes.

By default, it uses **A**dvanced **E**ncryption **S**tandard (AES) encryption in [**C**ipher **B**lock **C**haining (CBC)](bitlocker_encryption.md#cipher-block-chaining) or [**X**or-Encrypt-Xor (XEX)-based **T**weaked codebook](bitlocker_encryption.md#xex-based-tweaked-codebook-mode-with-ciphertext-stealing) mode with [ciphertext **S**tealing](bitlocker_encryption.md#ciphertext-stealing) (XTS) mode with a 128-bit or 256-bit key. CBC is not used over the whole disk, it is applied to each individual sector.

## Sources
- [BitLocker - Wikipedia](https://en.wikipedia.org/wiki/BitLocker)