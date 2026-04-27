FROM fedora:latest

RUN dnf install -y tang socat && dnf clean all

# Generate keys at build time instead of at every startup 
RUN mkdir -p /var/db/tang && /usr/libexec/tangd-keygen /var/db/tang

EXPOSE 7500

# Run tangd via socat since systemd-socket activation isn't standard in basic containers
# CMD socat TCP-LISTEN:7500,fork,reuseaddr EXEC:"/usr/libexec/tangd /var/db/tang"
CMD [ ! "$(ls -A /var/db/tang)" ] && /usr/libexec/tangd-keygen /var/db/tang; \
    socat TCP-LISTEN:7500,fork,reuseaddr EXEC:"/usr/libexec/tangd /var/db/tang"
