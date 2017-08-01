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

sleep 5
echo "node test run (profile 1)"
docker-compose run --rm -v $(pwd)/test-profiles/1.json:/app/test-profile.json node
sleep 5
echo "node test run (profile 2)"
docker-compose run --rm -v $(pwd)/test-profiles/2.json:/app/test-profile.json node

sleep 5
echo "go test run (profile 1)"
docker-compose run --rm -v $(pwd)/test-profiles/1.json:/go/src/app/test-profile.json node
sleep 5
echo "go test run (profile 2)"
docker-compose run --rm -v $(pwd)/test-profiles/2.json:/go/src/app/test-profile.json node

sleep 5
echo "ruby test run"
docker-compose run ruby
sleep 5
echo "elixir test run"
docker-compose run elixir
