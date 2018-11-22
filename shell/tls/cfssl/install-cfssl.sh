#!/bin/bash
# Author: JinsYin <jinsyin@github.com>

set -e

CFSSL_VERSION="1.2"

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

fn::install_cfssl() 
{
  local version=${1:-$CFSSL_VERSION}
  local components=(cfssl cfssljson cfssl-certinfo)

  fn::install_package wget

  for component in ${components[@]}; do
    if ! fn::command_exists ${component}; then
      wget https://pkg.cfssl.org/R${version}/${component}_linux-amd64 -O /usr/bin/${component}
      chmod +x /usr/bin/${component}
    fi
  done
}

main() {
  fn::check_permission
  fn::install_cfssl $@
}

main $@