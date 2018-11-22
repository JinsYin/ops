#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

set -e

CONSUL_VERSION="1.0.3"

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

fn::command_exists()
{
  command -v "$@" > /dev/null 2>&1
}

fn::package_exists()
{
  rpm -q $@ > /dev/null 2>&1
}

# Usage: fn::install_package wget net-tools
fn::install_package()
{
  for package in $@; do
    if ! fn::package_exists $package; then
      yum install -y $package
    fi
  done
}

fn::install_consul()
{
  local version=${1:-$CONSUL_VERSION}

  fn::install_package wget unzip

  if ! fn::command_exists consul; then
    rm -rf /tmp/consul* && mkdir -p /tmp/consul
    wget -O /tmp/consul.zip https://releases.hashicorp.com/consul/${version}/consul_${version}_linux_amd64.zip
    unzip /tmp/consul.zip -d /tmp/consul
    mv /tmp/consul/consul /usr/bin/ && chmod +x /usr/bin/consul
    rm -rf /tmp/consul*
  fi
}


main()
{
  fn::install_consul $@
}

main $@