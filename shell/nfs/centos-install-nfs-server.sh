#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

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

fn::install_nfs()
{
  fn::install_package rpcbind nfs-utils
}

fn::start_nfs_services()
{
  systemctl enable rpcbind nfs
  systemctl start rpcbind nfs
}

 
fn::mk_share_dir()
{
  mkdir /mnt/nfs

  echo "/export*(rw,async,no_root_squash,no_subtree_check)" >> /etc/exports

  # 刷新配置
  exportfs -a
}

main()
{
  fn::mk_share_dir $@
}

main $@