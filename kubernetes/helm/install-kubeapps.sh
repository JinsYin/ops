#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

set -e

KUBEAPPS_VERSION="v0.2.0"

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

fn::command_exists()
{
  command -v $@ > /dev/null 2>&1
}

fn::package_exists()
{
  rpm -q $@ > /dev/null 2>&1
}

# Usage: fn::instasll_package wget net-tools
fn::install_package()
{
  for package in $@; do
    if ! fn::package_exists $package; then
      yum install -y $package
    fi
  done
}

fn::install_kubeapps()
{
  local version=${1:-KUBEAPPS_VERSION}

  fn::install_package wget

  if ! fn::command_exists kubeapps; then
    wget https://github.com/kubeapps/installer/releases/download/${version}/kubeapps-linux-amd64 -O /usr/local/bin/kubeapps
    chmod +x /usr/local/bin/kubeapps
  fi
}

main()
{
  fn::check_permission
  fn::install_kubeapps $@
}

main $@