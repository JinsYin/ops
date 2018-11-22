#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

GLUSTERFS_VERSION="3.12.6"

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

fn::install_glusterfs_server()
{
  local version=${1:-$GLUSTERFS_VERSION}
  local repo_ver=$(echo $version | cut -d '.' -f1)$(echo $version | cut -d '.' -f2)

  # Dependencies: glusterfs glusterfs-api glusterfs-cli glusterfs-client-xlators glusterfs-fuse glusterfs-libs
  fn::install_package epel-release centos-release-gluster${repo_ver} glusterfs-server-${version}
}

fn::start_glusterfs_server()
{
  systemctl start glusterd
  systemctl enable glusterd
}

main()
{
  fn::check_permission
  fn::install_glusterfs_server $@
  fn::start_glusterfs_server
}

main $@