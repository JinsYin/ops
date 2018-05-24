#!/bin/bash
# Author: github.com/jinsyin

set -e

INFLUXDB_VERSION="1.4.2"

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

fn::command_exists() 
{
  command -v $@ > /dev/null 2>&1
}

fn::package_exists()
{
  rpm -q $@ > /dev/null 2>&1
}

# Usage: fn::instasll_package wget net-tools
fn::install_package()
{
  for package in $@; do
    if ! fn::package_exists $package; then
      yum install -y $package
    fi
  done
}

fn::install_influxdb_bin()
{
  local version=${1:-$INFLUXDB_VERSION}
  local components=(influx influxd influx_inspect influx_tsm influx_stress)

  # fn::install_package wget

  for component in $components; do
    if ! fn::command_exists ${component}; then
      rm -rf /tmp/influxdb* && mkdir -p /tmp/influxdb
      wget -O /tmp/influxdb.tar.gz https://dl.influxdata.com/influxdb/releases/influxdb-${version}_linux_amd64.tar.gz
      tar -zxf /tmp/influxdb.tar.gz -C /tmp/influxdb --strip-components=1
      cp /tmp/influxdb/influxdb-*/usr/bin/influx* /usr/bin/
      chmod +x /usr/bin/influx*
    fi
  done
}

main()
{
  fn::install_influxdb_bin $@
}

main $@
