#!/bin/bash
# Author: JinsYin <jinsyin@github.com>

set -e

CALICOCNI_VERSION="1.11.0"

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

fn::command_exists() {
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

fn::install_calico_cni()
{
  local version=v${1:-$CALICOCNI_VERSION}
  local components=(calico, calico-ipam)

  fn::install_package wget

  for component in ${components[@]} do
    if ! fn::command_exists ${component}; then
      wget -O /usr/bin/${component} https://github.com/projectcalico/cni-plugin/releases/download/${version}/${component}
      chmod +x /usr/bin/${component}
    fi
  done
}

main()
{
  fn::check_permission
  fn::install_calico_cni $@
}

main　$@