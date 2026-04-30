# Installation

## Prerequisites

### Tang server
- Docker installed
- Port **7500** reachable from the client LAN

### Ubuntu client
- Root disk already encrypted with **LUKS2**
- Wired network interface available
- **TPM 2.0** present and accessible
- LAN access to the Tang server (port 7500)
- Required packages (installed automatically by the script):
  `cryptsetup`, `clevis`, `clevis-luks`, `clevis-tpm2`, `clevis-initramfs`, `tpm2-tools`

---

## 1. Tang server (Docker)

Build and start the container:

```sh
# Build the image
docker build -t tang_server -f ./mvp/docker/Dockerfile ./mvp/docker/

# Run the container with a volume for keys
docker run -d --name tang-server -p 7500:7500 -v tang-keys:/var/db/tang tang_server
```

> Keys are generated automatically on first startup and persisted in the `tang-keys` volume.

---

## 2. Ubuntu client

### 2.1 Install Ubuntu with LUKS activated

### 2.2 Clone the repository
Please clone the `NathanAnto/305.2-Applied-Cybersecurity` repository.

```bash
git clone https://github.com/NathanAnto/305.2-Applied-Cybersecurity
```

### 2.3 Adapt the configuration script

Before running any script, open `MVP/config.env` and update the following variables to match your environment:

```bash
TANG_SERVER_URL="http://192.168.10.6:7500"

# Network (used for static IP in initramfs)
GATEWAY="192.168.10.1"
NETMASK="255.255.255.0"

# Systemd service (name must match the .service unit filename)
SERVICE_NAME="nbde-rebind"
 
# Install paths
NBDE_ENV_FILE="/etc/default/nbde"
SCRIPTS_INSTALL_DIR="/usr/local/lib/nbde"
UNIT_INSTALL_DIR="/etc/systemd/system"

# Logging tag (for logger / journald)
LOG_TAG="nbde"
```

### 2.4 Secure boot
To enable secure boot on the laptop and finish the configuration, open and do all steps from [Secure-Boot_with_UKI.md](secure-boot/Secure-Boot_with_UKI.md) document.