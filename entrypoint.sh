#!/bin/sh

# Taken from https://github.com/wurstmeister/kafka-docker/blob/master/start-kafka.sh
(
	function updateConfig() {
		key=$1
		value=$2
		file=$3

		echo "[Configuring] '$key' with '$value' in '$file'"

		# If config exists in file, replace it. Otherwise, append to file.
		if grep -E -q "^#?$key[[:space:]]" "$file"; then
			sed -r -i "s/^#?$key[[:space:]]+.*/$key $value/g" "$file"
		else
			echo "$key $value" >> "$file"
		fi
	}

	if [ -n "$SSHD_ALLOW_TCP_FORWARDING" ]; then
		updateConfig "AllowTcpForwarding" "$SSHD_ALLOW_TCP_FORWARDING" /etc/ssh/sshd_config
	fi

	if [ -n "$SSHD_TCP_KEEP_ALIVE" ]; then
		updateConfig "TCPKeepAlive" "$SSHD_TCP_KEEP_ALIVE" /etc/ssh/sshd_config
	fi

	if [ -n "$SSHD_CLIENT_ALIVE_INTERVAL" ]; then
		updateConfig "ClientAliveInterval" "$SSHD_CLIENT_ALIVE_INTERVAL" /etc/ssh/sshd_config
	fi

	if [ -n "$SSHD_CLIENT_ALIVE_COUNT_MAX" ]; then
		updateConfig "ClientAliveCountMax" "$SSHD_CLIENT_ALIVE_COUNT_MAX" /etc/ssh/sshd_config
	fi
)

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

# add users from csv file
if [ -f /etc/ssh/users.csv ]; then
	while IFS=, read login password_hash ssh_key; do
		[ -z "$login" ] && continue
	    echo "Add user $login"
		adduser -D -s /bin/sh -h /home/$login $login
		sed -i "s|$login:!:|$login:$password_hash:|" /etc/shadow
		if [ ! -z "$ssh_key" ]; then
			mkdir -p -m 0700 /home/$login/.ssh
			echo $ssh_key > /home/$login/.ssh/authorized_keys
			chmod 0600 /home/$login/.ssh/authorized_keys
			id=`id -u $login`
			chown -R $id /home/$login/.ssh
		fi
	done < /etc/ssh/users.csv
fi

exec "$@"
