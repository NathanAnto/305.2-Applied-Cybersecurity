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

**Implementation**

### 1.2 Single network segment

### 1.3 Tang server running in Docker

## 2. Physical security limitations

### 2.1 Theft of a client machine while powered on

### 2.2 Theft of device + eventual Tang server compromise

? ### 2.3 Cold boot attack

## 3. Insider threat / Administrative access

### 3.1 Administrator access to Tang private keys

### 3.2 No audit trail

## Key management limitations

### 4.1 Manual recovery 



## Device outside the corporate network