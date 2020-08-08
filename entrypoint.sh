#!/bin/sh

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

# prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

# enable tunneling
sed -ri "s/^(AllowTcpForwarding\s+)\S+/\1yes/" /etc/ssh/sshd_config

# add users from csv file
if [ -f /etc/ssh/users.csv ]; then
	while IFS=, read login password_hash ssh_key; do
		adduser -s /bin/sh -h /home/$login $login
		sed -i "s|$login:!:|$login:$password_hash:|" /etc/shadow
		if [ ! -z "$ssh_key" ]; then
			mkdir -p -m 0700 /home/$login/.ssh
			echo $ssh_key > /home/$login/.ssh/authorized_keys
			chmod 0600 /home/$login/.ssh/authorized_keys
			chown -R $login /home/$login/.ssh
		fi
	done < /etc/ssh/users.csv
fi

exec "$@"
