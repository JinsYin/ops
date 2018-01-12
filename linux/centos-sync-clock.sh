#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

NTP_POOL="cn.pool.ntp.org"

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

fn::centos::install_ntp()
{
  fn::install_package ntp
}

fn::centos::sync_clock()
{
  local ntppool=${1:-$NTP_POOL}
  ntpdate cn.pool.ntp.org
  hwclock -w
  systemctl enable ntpd
  systemctl restart ntpd
}

main()
{
  fn::centos::install_ntp
  fn::centos::sync_clock $@
}

main $@
