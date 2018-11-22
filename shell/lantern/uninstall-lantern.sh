#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

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

fn::ubuntu::unstall_lantern()
{
  if fn::command_exists lantern; then
    apt-get purge -y lantern
  fi
}

main()
{
  fn::check_permission
  fn::ubuntu::unstall_lantern
}

main $@
