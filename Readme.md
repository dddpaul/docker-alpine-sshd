# Alpine SSH server

## Instructions

### Key based usage (preferred)

Copy the id_rsa.pub from your workstation to your dockerhost.
On the dockerhost create a volume to keep your authorized_keys.

```bash
tar cv --files-from /dev/null | docker import - scratch
docker create -v /root/.ssh --name ssh-container scratch /bin/true
docker cp id_rsa.pub ssh-container:/root/.ssh/authorized_keys
```

For ssh key forwarding use ssh-agent on your workstation.

```bash
ssh-agent
ssh-add id_rsa
```

Then the start sshd service on the dockerhost (check the tags for alpine versions)

```bash
docker run -p 4848:22 --name alpine-sshd --hostname alpine-sshd --volumes-from ssh-container  -d dddpaul/alpine-sshd
```

### Password based

```bash
docker run -p 4848:22 --name alpine-sshd --hostname alpine-sshd -d dddpaul/alpine-sshd
docker exec -ti alpine-sshd passwd
```

### From your workstation

ssh to your new docker environment, with an agent the -i option is not needed

```bash
ssh -p 4848 -i id_rsa root@<dockerhost>
```

### Import users from CSV file

Mount an CSV file to /etc/ssh/users.csv to generate users inside container at startup time.

CSV file format (trailing empty line is required):

```csv
login1,password_hash1,
login2,password_hash2,ssh_public_key
...

```

For testing (password is "qwerty"):

```bash
make run
ssh -p 10022 test_user@localhost
```

### Configuration

Set the following environment variables to pass values to `/etc/ssh/sshd_config` inside container:

* SSHD_ALLOW_TCP_FORWARDING
* SSHD_TCP_KEEP_ALIVE
* SSHD_CLIENT_ALIVE_INTERVAL
* SSHD_CLIENT_ALIVE_COUNT_MAX
* SSHD_LOG_LEVEL
* SSHD_PUBKEY_AUTHENTICATION
* SSHD_PASSWORD_AUTHENTICATION

See `man sshd_config` for detailed information.
