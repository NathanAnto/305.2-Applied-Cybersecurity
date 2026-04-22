# Clevis and Tang as a Key Management System (KMS)

For our specific project, a good solution would be to use **Clevis** for automated encryption and a **Tang** server for decryption in LAN. This method is called Network-Bound Disk Encryption (NBDE).

1. Initramfs loads: Ubuntu starts the network stack and the TPM driver.
2. Clevis initiates [SSS](https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing): It sees the LUKS2 JSON token and realizes it needs two shares to unlock the drive.
3. TPM Unseal: Clevis asks the TPM for Share A. If the BIOS/Kernel hasn't been tampered with, the TPM releases it.
4. Tang Exchange: Clevis performs an Elliptic Curve Diffie-Hellman (ECDH) exchange with the Tang server over the LAN to recover Share B.
    - *Crucially: The client never sends its secret to the Tang server. It sends a "blinded" key, and Tang responds with a mathematical transform that allows the client to recover Share B.*
5. Reconstruction: Clevis mathematically combines Share A + Share B to recreate the original secret.
6. Unlock: That secret is fed into cryptsetup to open the LUKS2 container.

## What is Clevis

Clevis is an encryption automation tool that uses luks encryption 


## What is Tang

Tang is a server for binding data to a network presence, so in our case, it helps us force a system to have access to the Tang server, before being able to decrypt the drive.

Tang was made to work with Clevis, so integration with both is simple.

## Setup

### Tang server

Run these commands on a Fedora system (I used a docker container for the demo)

Dockerfile for Tang server image:
```docker
FROM fedora:latest
RUN dnf install -y tang socat && dnf clean all
RUN mkdir -p /var/db/tang
EXPOSE 7500
# Run tangd via socat since systemd-socket activation isn't standard in basic containers
CMD /usr/libexec/tangd-keygen /var/db/tang && \
    socat TCP-LISTEN:7500,fork,reuseaddr EXEC:"/usr/libexec/tangd /var/db/tang"
```

Then build and run the server:
```sh
# Build the image
docker build -t tang_server -f Dockerfile.tang .

# Run the container with a volume for keys
docker run -d --name tang-server -p 7500:7500 -v tang-keys:/var/db/tang tang_server
```

#### McCallum-Relyea

[McCallum-Relyea key exchange](https://access.redhat.com/articles/6987053#mccallum-relyea-key-exchange-3) is an alternative method to key escrow that allows the regeneration of a decryption key without requiring its retrieval. This algorithm is an advanced version of the Diffie-Hellman key exchange algorithm. 

### Clevis

Bind the device to the TPM (pcr 7) and to the Tang server.
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

```sh
sudo clevis luks unlock -d /dev/sdb -n usb_crypt
```

#### Shamir's Secret Sharing (SSS)

Clevis uses [Shamir's Secret Sharing](https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing) to share the secret between the TPM and the Tang server.

## Conclusion

This is a good method for a 2FA type encryption, but is missing important features, like detailed audit logs and more robust authentication.

## Sources

[NBDE (Network-Bound Disk Encryption) Technology](https://access.redhat.com/articles/6987053)