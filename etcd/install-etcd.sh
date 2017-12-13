#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

set -e

ETCD_VERSION="3.2.9"

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

fn::install_etcd()
{
  local version=v${1:-$ETCD_VERSION}
  local components=(etcd etcdctl)

  fn::install_package wget

  for component in ${components[@]}; do
    if ! fn::command_exists ${component}; then
      rm -rf /tmp/etcd* && mkdir -p /tmp/etcd
      wget -O /tmp/etcd.tar.gz https://github.com/coreos/etcd/releases/download/${version}/etcd-${version}-linux-amd64.tar.gz
      tar -xzf /tmp/etcd.tar.gz -C /tmp/etcd --strip-components=1
      mv /tmp/etcd/{etcd,etcdctl} /usr/bin/ && chmod a+x /usr/bin/{etcd,etcdctl}
      rm -rf /tmp/etcd*
    fi
  done
}

main()
{
  fn::check_permission
  fn::install_etcd $@
}

main $@