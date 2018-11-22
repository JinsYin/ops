#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

set -e

PROMETHEUS_VERSION="2.0.0"

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

# promtool: client
# prometheus: server
fn::install_prometheus()
{
  local version=${1:-$PROMETHEUS_VERSION}
  local components=(prometheus promtool)

  fn::install_package wget

  for component in ${components}; do
    if ! fn::command_exists ${component}; then
      rm -rf /tmp/prometheus* && mkdir -p /tmp/prometheus
      wget -O /tmp/prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-amd64.tar.gz
      tar -zxf /tmp/prometheus.tar.gz -C /tmp/prometheus --strip-component=1
      cp /tmp/prometheus/{prometheus,promtool} /usr/bin/
      chmod +x /usr/bin/{prometheus,promtool}
    fi
  done
}

main()
{
  fn::install_prometheus $@
}

main $@
