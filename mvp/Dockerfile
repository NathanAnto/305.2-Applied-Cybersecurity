FROM fedora:latest

RUN dnf install -y tang socat && dnf clean all

# Generate keys at build time
RUN mkdir -p /var/db/tang && /usr/libexec/tangd-keygen /var/db/tang

EXPOSE 7500

CMD socat TCP-LISTEN:7500,fork,reuseaddr EXEC:"/usr/libexec/tangd /var/db/tang"