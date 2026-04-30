#!/bin/bash

lsblk -lo NAME,UUID | awk '$1 == "ubuntu--vg-ubuntu--lv" {print $2}'
