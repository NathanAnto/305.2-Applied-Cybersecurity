#!/bin/bash

sudo cp -r /mnt/keys /var/lib/sbctl/
sudo sbctl enroll-keys
sudo rm -rf /var/lib/sbctl/keys
