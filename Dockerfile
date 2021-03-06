FROM alpine:3.12
LABEL maintainer="Pavel Derendyaev <dddpaul@gmail.com>"

RUN apk add --update openssh iputils lsof sed \
    && rm  -rf /tmp/* /var/cache/apk/* \
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key \
    && passwd -d root

ADD entrypoint.sh /

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
