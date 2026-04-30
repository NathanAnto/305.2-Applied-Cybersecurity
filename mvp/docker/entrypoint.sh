#!/bin/sh
set -e

# Ensure the database directory exists
mkdir -p /var/db/tang

# Generate keys if the directory is empty
if [ -z "$(ls -A /var/db/tang)" ]; then
    /usr/libexec/tangd-keygen /var/db/tang
fi

# Execute the main process
exec socat TCP-LISTEN:7500,fork,reuseaddr EXEC:'/usr/libexec/tangd /var/db/tang'