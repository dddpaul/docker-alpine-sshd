FROM alpine:edge
MAINTAINER Pavel Derendyaev <dddpaul@gmail.com>

ADD docker-entrypoint.sh /usr/local/bin

RUN apk add --update openssh \
    && rm  -rf /tmp/* /var/cache/apk/* \
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key \
    && passwd -d root

EXPOSE 22
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd","-D"]
