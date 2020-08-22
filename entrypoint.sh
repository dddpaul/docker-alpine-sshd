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

	startswith() { case $2 in "$1"*) true;; *) false;; esac; }

    # Read in env as a new-line separated array. This handles the case of env variables have spaces and/or carriage returns.
    IFS=$'\n'
    for env_var in $(env); do
        env_name=$(echo "$env_var" | cut -d= -f1)
		if startswith SSHD_ "$env_name"; then
			sshd_name=$(echo "$env_name" | cut -d_ -f2- | tr '[:upper:]' '[:lower:]' | sed -E 's/(^|_)([a-z])/\U\2/g')
			env_val=$(printenv $env_name)
			updateConfig "$sshd_name" "$env_val" /etc/ssh/sshd_config
		fi
	done
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
	    echo "[Adding] user '$login'"

		home="/home/$login"
		if [ "$login" == "root" ]; then
			home="/root"
		fi

		if [ "$login" != "root" ]; then
			adduser -D -s /bin/sh -h $home $login
		fi
		sed -i -E "s|$login:!?|$login:$password_hash|" /etc/shadow

		if [ ! -z "$ssh_key" ]; then
			mkdir -p -m 0700 /$home/.ssh
			echo $ssh_key > /$home/.ssh/authorized_keys
			chmod 0600 /$home/.ssh/authorized_keys
			id=$(id -u $login)
			chown -R $id /$home/.ssh
		fi
	done < /etc/ssh/users.csv
fi

exec "$@"
