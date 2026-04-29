FROM fedora:40

RUN dnf install -y tang socat && dnf clean all

# Copy the script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 7500

CMD ["entrypoint.sh"]