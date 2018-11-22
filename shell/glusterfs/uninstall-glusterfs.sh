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

# Usage: fn::uninstall_package wget net-tools
fn::uninstall_package()
{
  for package in $@; do
    if ! fn::package_exists $package; then
      yum remove -y $package
    fi
  done
}

fn::uninstall_glusterfs()
{
  if fn::command_exists glusterfs; then
    yum remove -y gluster*
  fi
}

fn::remove_glusterfs_data()
{
  rm -r /var/lib/glusterd
}

main()
{
  fn::check_permission
  fn::uninstall_glusterfs
}

main $@