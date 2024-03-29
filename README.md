JudoAssistant Server Config
===========================
This repository contains the configuration files for the JudoAssistant web
server.
This README is to be used as documentation and not as a step-by-step guide on
how to setup a web server for JudoAssistant.
All services are deployed as docker containers managed by docker compose.

Setup Guide
-----------
Start by creating a Digital Ocean droplet on Ubuntu LTS and perform the
following steps:
```bash
adduser svendcs # add user svendcs
adduser ci # add user ci
passwd # set root password
passwd svendcs # set svendcs password
passwd ci # set ci password
usermod -a -G admin svendcs # add svendcs to admin group
```

Next, copy your public keys into `.ssh/authorized_keys` for users `ci` and `svendcs`.
Afterwards, disable root shh login. Proceed by upgrading the system and
installing some useful packages:
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
ufw allow 9000/tcp # backend tcp streams
ufw enable
```

Afterwards, make sure that you have digital ocean metrics installed
([instructions](https://www.digitalocean.com/docs/monitoring/how-to/install-agent/))
and reboot the system.

We now wish to setup the letsencrypt keys. We use the digital ocean dns plugin
for certbot. Follow the steps described [here](https://certbot-dns-digitalocean.readthedocs.io/en/stable/)
to create the file `/var/certbot/digital_ocean_credentials.ini`. Make sure to `chmod 400`
the file afterwards. Next, obtain your certificate using certbot standalone mode:

```bash
certbot certonly --dns-digitalocean --dns-digitalocean-credentials /var/certbot/digital_ocean_credentials.ini -d judoassistant.com -d live.judoassistant.com
```

WWW Directories
---------------
The CI/CD system automatically deploys static html files to the server. In
order for this to work, it is neccessary to create the correct folder on the
system:
```bash
sudo mkdir -p /var/www/live.judoassistant.com/html
sudo chown ci:ci /var/www/live.judoassistant.com/html
sudo mkdir -p /var/www/judoassistant.com/html
sudo chown ci:ci /var/www/judoassistant.com/html
sudo mkdir -p /var/www/builds.judoassistant.com/releases
sudo chown ci:ci /var/www/builds.judoassistant.com/releases
sudo mkdir -p /var/www/builds.judoassistant.com/master
sudo chown ci:ci /var/www/builds.judoassistant.com/master
```


Database Initialization
-----------------------
In order to initialize the database and run migrations, use the judoassistant
alembic docker image. First, clone the [JudoAssistant git repository](https://github.com/judoassistant/judoassistant) and create the `alembic.ini` file from the template. Afterwards, you can run the migration tool on the postgres database as follows:
```bash
sudo docker run --rm --network judoassistant-server-config_default -v $(pwd)/alembic.ini:/alembic.ini -v $(pwd)/alembic:/alembic/alembic:ro judoassistant/alembic --help
```

Managing the database
---------------------
Managing the users and tournaments in the database is currently done using the
server-toolkit. There is a docker image created for this purpose:
```bash
source .env
sudo docker run --rm --network judoassistant-server-config_default -e DATABASE_URL=${DATABASE_URL} judoassistant/judoassistant-server-toolkit --help
```
