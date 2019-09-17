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

fn::ubuntu::install_latest_lantern()
{
  local url=https://raw.githubusercontent.com/getlantern/lantern-binaries/master/lantern-installer-64-bit.deb
  local tmp_deb=/tmp/lantern.deb

  if ! fn::command_exists lantern; then
    rm -rf /tmp/lantern* && wget -O ${tmp_deb} ${url}
    dpkg -i ${tmp_deb} && rm -f ${tmp_deb}
  fi
}

main()
{
  fn::check_permission
  fn::ubuntu::install_latest_lantern
}

main $@
