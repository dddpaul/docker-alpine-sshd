FROM alpine:edge
LABEL maintainer="Pavel Derendyaev <dddpaul@gmail.com>"

RUN apk add --update openssh \
    && rm  -rf /tmp/* /var/cache/apk/* \
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key \
    && passwd -d root

ADD docker-entrypoint.sh /usr/local/bin

EXPOSE 22
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd","-D"]
