#!/bin/bash

lsblk -lo NAME,FSTYPE | awk '$2 == "crypto_LUKS" {print $1}'
