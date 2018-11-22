#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

set -e

K8S_VERSION="1.8.2"

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

fn::rm-cni-conf-dir()
{
  if [ -d /etc/cni/net.d ]; then
    rm -rf /etc/cni/*
  fi
}

fn::rm-cni-bin-dir()
{
  if [ -d /opt/cni/bin ]; then
    rm -rf /opt/cni/*
  fi
}

main()
{
  fn::check_permission
  fn::rm-cni-conf-dir
  fn::rm-cni-bin-dir
}

main $@
