#!/bin/bash

sudo efibootmgr --create --disk /dev/nvme0n1 --part 1 --label "305.2 Boot image" --loader '\EFI\Linux\3052_uki.efi'
