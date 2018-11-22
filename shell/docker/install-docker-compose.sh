#!/bin/bash

VERSION="1.8.1"

curl -L "https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

echo "alias dc='docker-compose'" >> ~/.zshrc
