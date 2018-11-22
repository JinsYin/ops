#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You need to be root to perform this command."
    exit 1
  fi
}

fn::disable_selinux() 
{
  setenforce 0

  sed -i -e 's|SELINUX=enforcing|SELINUX=disabled|g' /etc/selinux/config
}

fn::disable_and_reboot() 
{
  fn::disable_selinux
  reboot
}