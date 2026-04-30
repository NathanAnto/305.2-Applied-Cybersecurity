#!/bin/bash

lsblk -lo FSTYPE,UUID | awk '$1 == "crypto_LUKS" {print $2}'
