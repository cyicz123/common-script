#!/bin/bash
# Install docker and docker-compose.
# Configure the ipv6 of docker
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
if ! type wget >/dev/null 2>&1; then
    echo 'Installing wget'
    apt-get update && apt-get install -y wget
fi

echo 'Installing docker and docker-compose'
wget -qO- get.docker.com | bash
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo 'Configuring docker ipv6'
cat > /etc/docker/daemon.json << EOF
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:abc1::/64", 
  "experimental": true,
  "ip6tables": true
}
EOF
systemctl restart docker

if [[ $(docker network inspect bridge | grep "EnableIPv6") =~ 'false' ]]
then
    echo 'ipv6 start failed. Exit.' 1>&2
    exit 1
fi