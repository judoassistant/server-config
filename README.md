JudoAssistant Server Config
===========================
This repository contains the configuration files for the JudoAssistant web
server.
All services are deployed as docker containers managed by docker compose.

Setup Guide
-----------
Start by creating a Digital Ocean droplet on Ubuntu 20.04 and perform the
following steps:
```bash
adduser svendcs # add user svendcs
adduser ci # add user ci
passwd # set root password
passwd svendcs # set svendcs password
passwd ci # set ci password
usermod -a -G admin svendcs # add svendcs to admin group
```

Now copy public keys into `.ssh/authorized_keys` for `ci` and `svendcs`.
Afterwards disable root shh login. Proceed by upgrading the system and
installing the neccesary packages:
```bash
apt update
apt upgrade
apt install neovim docker docker-compose ufw python3-certbot-dns-digitalocean
```

Setup the firewall rules:
```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw enable
```

Afterwards make sure that you have digital ocean metrics installed
(https://www.digitalocean.com/docs/monitoring/how-to/install-agent/)
and reboot the system.

We now wish to setup the letsencrypt keys. We use the digital ocean dns plugin
for certbot. Follow the steps described [here](https://certbot-dns-digitalocean.readthedocs.io/en/stable/)
to create the file `/var/certbot/digital_ocean_credentials.ini` and `chmod 400`
the file. Create the certificates using cerbot standalone mode:

```bash
certbot certonly --dns-digitalocean --dns-digitalocean-credentials /var/certbot/digital_ocean_credentials.ini -d judoassistant.com -d live.judoassistant.com
````

Database Initialization
-----------------------
In order to initialize the database and run migrations you can use the
judoassistant alembic docker image. First pull the judoassistant main git repo
and create the `alembic.ini` file from the template file.

You can then run the migrations on the postgres database as follows:
```bash
sudo docker run --rm --network judoassistant-server-config_default -v $(pwd)/alembic.ini:/alembic.ini -v $(pwd)/alembic:/alembic/alembic:ro judoassistant/alembic upgrade head
```
