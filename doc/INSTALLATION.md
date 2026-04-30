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
docker build -t tang_server -f Dockerfile.tang .

# Run the container (with a persistent volume for keys)
docker run -d --name tang-server \
  -p 7500:7500 \
  -v tang-keys:/var/db/tang \
  tang_server
```

> Keys are generated automatically on first startup and persisted in the `tang-keys` volume.

---

## 2. Ubuntu client

### 2.1 Adapt the configuration script

Before running the script, open `MVP/config.env` and update the following variables to match your environment:

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

### 2.2 Run the installation script

```sh
sudo bash MVP/scripts/install.sh
```

The script performs the following steps:

1. Installs the required packages and dependencies
2. Installs the network hook into initramfs (`/etc/initramfs-tools/hooks/clevis-network`)
3. Configures a static IP for the initramfs phase (`/etc/initramfs-tools/conf.d/static_ip`)
4. Prompts to perform the Clevis binding (TPM2 + Tang via Shamir Secrect Sharing )
5. Regenerates the initramfs (`update-initramfs -u -k all`)