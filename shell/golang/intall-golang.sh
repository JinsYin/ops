#!/bin/bash

GO_VERSION="1.10"

function install_go()
{

  wget -O /tmp/go.tar.gz https://dl.google.com/go/go1.10.linux-amd64.tar.gz

  tar -C /usr/local -xzf go1.10.linux-amd64.tar.gz

  # centos system-wide
  echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile 
  source /etc/profile

  # ubuntu system-wide
  echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
  source ~/.bashrc

  go version
}

main()
{

}

main $@