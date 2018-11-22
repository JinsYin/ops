#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

fn::package_exists()
{
  rpm -q $@ > /dev/null 2>&1
}

# Usage: fn::remove_package wget net-tools
fn::remove_package()
{
  for package in $@; do
    if fn::package_exists $package; then
      yum remove -y $package
    fi
  done
}

fn::centos::unstall_docker()
{
  # 移除非官方的 docker 包
  fn::remove_package docker docker-common container-selinux docker-selinux

  # 移除官方的 docker 包
  fn::remove_package docker-engine-selinux docker-engine
}

main()
{
  fn::check_permission
  fn::centos::unstall_docker
}

main $@