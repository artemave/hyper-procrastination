#!/bin/bash

apt-get remove -y docker docker-engine

apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

apt-get update -y
apt-get install -y docker-ce
curl -L "https://github.com/docker/compose/releases/download/1.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

cd /vagrant

echo "Starting nginx"
docker-compose start nginx
sleep 5
echo "node test run"
docker-compose run node
sleep 5
echo "go test run"
docker-compose run go
sleep 5
echo "ruby test run"
docker-compose run ruby
