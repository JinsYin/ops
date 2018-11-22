#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>
# 在当前目录下生成卸载模板

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