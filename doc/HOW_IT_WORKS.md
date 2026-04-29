# How It Works

## Architecture overview

Unlocking requires **both** conditions simultaneously:

```
Boot
 ├── TPM 2.0 ──────────────────── Share A ───┐
 │   (validates boot chain integrity)        ├──► Clevis SSS ──► LUKS2 passphrase ──► Disk unlocked
 └── Tang server ────────────────  Share B ──┘
     (reachable on the network)
```

If either share is missing, the disk **stays locked**.

---

## Boot sequence

During boot, the initramfs executes the following sequence:

| Phase | Step | Action |
|-------|------|--------|
| 1 | Kernel | Loads and decompresses initramfs into memory |
| 2 | `init-top` | Starts udev, initializes userspace |
| 3 | `init-premount` | Loads kernel modules (network, TPM) |
| 4 | `local-premount` | Network initialization (DHCP / static IP) |
| 5 | `local-top` | Clevis reads the LUKS2 token, contacts Tang + queries TPM2, reconstructs the secret (SSS), runs `cryptsetup open` |
| 6 | `switch_root` | Root filesystem mounted, handoff to systemd (PID 1) |

---

## Role of the initramfs

The initramfs (initial RAM filesystem) is a temporary filesystem loaded into memory by the kernel **before** the actual root filesystem is available.

In this project it has been customized to include:
- **Network scripts** — bring up the network interface with a static IP early in the boot process
- **Clevis + dependencies** — reconstruct the LUKS2 passphrase from both shares before `switch_root`

Without these additions, the standard Ubuntu initramfs has no network stack and no knowledge of Clevis, so the disk would remain locked.

---

## Cryptographic protocol

### Shamir's Secret Sharing (SSS)

The LUKS2 passphrase is split into **two shares** at binding time:

- **Share A** → sealed into the TPM2 (bound to specific PCR values)
- **Share B** → derived via the Tang / McCallum-Relyea exchange

Both shares are required to reconstruct the secret. One share alone reveals nothing.

### McCallum-Relyea (Tang side)

Tang implements an **ECDH-based** key derivation protocol:

1. The client generates an ephemeral key pair and sends the public part to Tang
2. Tang performs the operation (based on the Diffie-Hellman algorithm + Integrated Encryption Scheme) with its own key and returns the result
3. The client combines the result with its ephemeral private key to derive Share B

> The client's private key **never leaves the machine**. Tang sees only a public point and returns a derived value, it never learns the actual secret.

### TPM2 (local side)

The TPM2 seals Share A against a set of **PCR (Platform Configuration Register)** values that reflect the state of the boot chain (firmware, bootloader, kernel). If any measured component is modified, the PCR values change and the TPM2 refuses to unseal Share A.

---

## Blocking scenarios

| Scenario | Share A (TPM2) | Share B (Tang) | Result |
|----------|:--------------:|:--------------:|--------|
| Normal boot | ✅ | ✅ | Unlocked |
| Tang unreachable | ✅ | ❌ | Boot blocked |
| Tang key revoked / rotated | ✅ | ❌ | Boot blocked |
| BIOS / Kernel tampered | ❌ | ✅ | Boot blocked |
| Disk cloned on another machine | ❌ | ✅ | Boot blocked (different TPM2) |
| Stolen device + Tang key compromised | ✅ | ✅ | Unlocked (key rotation required) |