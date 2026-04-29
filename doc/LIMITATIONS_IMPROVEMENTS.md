# Limitations and Improvements
This document identifies the known limitations of the current MVP implementation and proposes concrete improvement paths for each one.
> **Current deployment model**: Simple scenario, one Tang server, one client, single network segment.  
![tang_clevis_simple](images/tangclevissimplescenario.png)

https://access.redhat.com/articles/6987053

## Table of contents
1. [Infrastructure limitations](#1-infrastructure-limitations)

## 1. Infrastructure limitations

### 1.1 Single point of failure: Tang Server
**Limitation**

The current setup relies on a single Tang server. If that server becomes unavailable (crash, network outage, planned maintenance), **all bound clients are blocked from booting automatically**. They will retry indefinitely until the Tang server comes back.

**Improvement: Load-balanced Tang servers**

Add a second network segment, each with its own Tang server. Clevis is configured with an SSS pin that requires a threshold across both segments. This eliminates both the single-server and single-segment failure points:

![tang_clevis_load-balanced](images/tangclevissimpleloadbalancediskbalancescenario.png)

https://access.redhat.com/articles/6987053

**future implementation**

### 1.2 Single network segment
**Limitation**
A network outage on the isngle LAN segment simultaneously cuts off the Tang server and prevents clients from booting. There is no fallback path.

**Improvement**
Redundant network segments and/or a secondary network interface on the client (bonding / failover) configured in the initramfs network hook.

![tang_clevis_load-balanced_multi_network](images/tangclevisnetworkredundancyallbalancedloadbalancediskbalancescenario.png)

https://access.redhat.com/articles/6987053
**future implementation**

### 1.3 Tang server running in Docker
**Limitation**
The Tang server is containerized with minimal configuration: no authentication, no firewall rules defined in the project, no SELinux policy. Anyone with LAN access can query it.

**Improvement**
- Restrict access to port 7500 to the known client subnet via firewall rules
- Deploy Tang on a dedicated, hardened VM with SELinux in enforcing mode (as recommended in RHEL documentation: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/security_hardening/index).
**future implementation**

## 2. Physical security limitations

### 2.1 Theft of a client machine while powered on
**Limitation**
If a machine is stolen while already **booted and running**, the disk is unlocked and data is accessible. LUKS only protects data at rest, it cannot protect a live, running system.

**Improvement**
- Enforce automatic screen locking and session timeout
- Use full RAM encryption (Intel TME) for in-memory data protection.
**future implementation**

### 2.2 Theft of device + eventual Tang server compromise
**Limitation**
If an attacker steals the device and later gains access to the Tang server (or its key material), they can reconstruct both shares and decrypt the disk.
**Improvement**
Immediately perform key rotation upon detecting any theft or suspected compromise:
1. Generate new keys on the Tang server.
2. Rebind all remaining clients.
3. Delete the old keys only after all clients are rebound.

**future implementation**


## 3. Insider threat / Administrative access

### 3.1 Administrator access to Tang private keys
**Limitation**
The Tang server's private keys are stored in /var/tang (or in the tang-keys Docker volume). A system administrator with access to the Tang server can extract these keys and, combined with a stolen client disk, decrypt the data offline.

**Improvement**
- Store Tang private keys in a Hardware Security Module (HSM) so they never exist in plaintext on disk.
- Apply role separation: the admin who manages the Tang server should not have physical access to client machines, and vice versa.
- Enable audit logging on the Tang server to record all access to the key directory.

**future implementation**

### 3.2 No audit trail
**Limitation**
In the current setup, there is no logging of when a client successfully (or unsuccessfully) contacts the Tang server to unlock its disk. An unauthorized unlock goes undetected.
**Improvement**
Tang logs all client connections natively via `systemd-journald`. Each unlock attempt appears as a journal entry containing the client IP, the HTTP method and key ID.
- Ensure journald stores logs persistently (survives reboots) and with retention: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/automating_system_administration_by_using_rhel_system_roles_in_rhel_7.9/configuring-the-systemd-journal-by-using-the-journald-rhel-system-role_automating-system-administration-by-using-rhel-system-roles

- Forward Tang logs to a remote syslog server or SIEM (ex. Graylog) so that logs are tamper-resistant even if the Tang host is compromised.
**future implementation**

## Key management limitations

### 4.1 Manual recovery 
**Limitation**
If the Tang server is unreachable (network outage, maintenance), the only way to boot a client is to manually type the LUKS passphrase. This passphrase is the emergency fallback registered in the LUKS keyslot during initial setup. Communicating it to an on-site operator exposes it.

**Improvement**
- Store the emergency passphrase in a password vault (ex. HashiCorp Vault) with access controls and audit logging.

**future implementation**


## Device outside the corporate network