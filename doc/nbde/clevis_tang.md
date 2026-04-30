# Clevis and Tang for Network Based Disk Encryption (NBDE)
***By Nathan Antonietti - 305.2 : Cybersecurity***

Strictly speaking, Tang isn't a KMS because it doesn't store anything, it is stateless. But for our specific project, it's a good solution to use **Clevis** for automated encryption and a **Tang** server for decryption in LAN. This method is called Network-Bound Disk Encryption (NBDE).

For our example, we split our secret into 2 shares that are both required, but when using Clevis, you can define as many shares as you like, while defining the minimum amount of shares necessary to unlock the secret.

1. Initramfs loads: Ubuntu starts the network stack and the TPM driver.
2. Clevis initiates [SSS](https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing): It sees the LUKS2 JSON token and realizes it needs two shares to unlock the drive.
3. TPM Unseal: Clevis asks the TPM for Share A. If the BIOS/Kernel hasn't been tampered with, the TPM releases it.
4. Tang Exchange: Clevis performs an Elliptic Curve Diffie-Hellman (ECDH) exchange with the Tang server over the LAN to recover Share B.
    - *Crucially: The client never sends its secret to the Tang server. It sends a "blinded" key, and Tang responds with a mathematical transform that allows the client to recover Share B.*
5. Reconstruction: Clevis mathematically combines Share A + Share B to recreate the original secret.
6. Unlock: That secret is fed into cryptsetup to open the LUKS2 container.

## What is Clevis

Clevis is an encryption automation tool that uses LUKS encryption. It is used during the initramfs phase to automate disk encryption using pins, which is the name for the TPM or/and Tang backends.

By default, dm-crypt doesn't use the TPM. With Clevis we can use the TPM by defining the PCR Registers we want to watch (more about the TPM [here](../tpm/tpm.md)).

## What is Tang

Tang is a server for binding data to a network presence, so in our case, it helps us force a system to have access to the Tang server, before being able to decrypt the drive.

Tang was made to work with Clevis, so integration with both is simple. Learn more about Tang [here](../nbde/tang.md)

## Setup

### Tang server

Run these commands on a Fedora system (I used a docker container for the demo)

Dockerfile for Tang server image: [](../../mvp/docker/Dockerfile)

Then build and run the server:
```sh
# Build the image
docker build -t tang_server -f ./mvp/docker/Dockerfile ./mvp/docker/

# Run the container with a volume for keys
docker run -d --name tang-server -p 7500:7500 -v tang-keys:/var/db/tang tang_server
```

#### Key Rotation

Implementing automated key rotation is a crucial security feature. It ensures that if an attacker is using "brute force" methods on a specific key, the key expires before they can successfully crack it.

We can rotate the keys in the Tang server using:

```sh
/usr/libexec/tangd-rotate-keys -d /var/db/tang
```

But once the keys are rotated, all clients must rebind to the new keys before the old ones are deleted:
```sh
clevis luks regen -d /dev/nvme0n1p3 -s 1
```

[clevis-luks-regen](https://manpages.ubuntu.com/manpages/resolute/man1/clevis-luks-regen.1.html)

This can be done in a systemd service that is enabled on startup.

#### McCallum-Relyea

[McCallum-Relyea key exchange](https://access.redhat.com/articles/6987053#mccallum-relyea-key-exchange-3) is an alternative method to key escrow that allows the regeneration of a decryption key without requiring its retrieval. This algorithm is an advanced version of the Diffie-Hellman key exchange algorithm. 

### Clevis

Bind the device to the TPM (PCR 7) and to the Tang server.

```sh
sudo clevis luks bind -d /dev/sdX sss \
'{
  "t": 2,
  "pins": {
    "tpm2": {"pcr_ids":"7"},
    "tang": {"url":"http://172.17.0.1:7500"}
  }
}'
```

PCR 7 is the hash for Secure Boot, meaning that if the Secure Boot changes state after the bind, Clevis won't decrypt the disk. More info about PCRs [here](../tpm/tpm_doc.md#platform-configuration-registers-pcrs)

```sh
sudo clevis luks unlock -d /dev/sdb -n usb_crypt
```

#### Shamir's Secret Sharing (SSS)

Clevis uses [Shamir's Secret Sharing](https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing) to share the secret between the TPM and the Tang server.

## Conclusion

This is a good method for a 2FA type encryption, but is missing important features, like detailed audit logs and more robust authentication.

## Sources

[NBDE (Network-Bound Disk Encryption) Technology](https://access.redhat.com/articles/6987053)