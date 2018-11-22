#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>
# 官方默认构建的时候开启了 OpenCL 而关闭了 CUDA，所以需要自己构建（开启 CUDA 后性能后算力会有略微提升）

set -e

ETHMINER_VERSION="0.13.0"

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

fn::lsb_dist_name()
{
  if fn::command_exists lsb_release; then
    os=$(lsb_release -si)
  elif [ -f /etc/os-release ]; then
    os=$(. /etc/os-release && echo $ID)
  else
    os=$(uname -s)
  fi
  
  echo $os | tr '[:upper:]' '[:lower:]'
}

fn::lsb_dist_version()
{
  if fn::command_exists lsb_release; then
    version=$(lsb_release -sr)
  elif [ -f /etc/os-release ]; then
    version=$(. /etc/os-release && echo $VERSION_ID)
  else
    version=$(uname -r)
  fi

  echo $version | tr '[:upper:]' '[:lower:]'
}

fn::ubuntu::package_exists()
{
  dpkg -s $@ | grep 'Status:' | grep 'install ok installed' > /dev/null 2>&1
}

fn::centos::package_exists()
{
  rpm -q $@ > /dev/null 2>&1
}

fn::ubuntu::install_package()
{
  for package in $@; do
    if ! fn::ubuntu::package_exists $package; then
      apt-get install -y $package
    fi
  done
}

fn::centos::install_package()
{
  for package in $@; do
    if ! fn::centos::package_exists $package; then
      yum install -y $package
    fi
  done
}

# Usage: fn::install_package wget net-tools
fn::install_package()
{
  local lsb_dist_name=$(fn::lsb_dist_name)

  case $lsb_dist_name in
    ubuntu)
      fn::ubuntu::install_package $@
    ;;
    centos)
      fn::centos::install_package $@
    ;;
  esac
}

fn::install_ethminer()
{
  local version=${1:-$ETHMINER_VERSION}

  fn::install_package wget

  if ! fn::command_exists ethminer || [ -z "$(ethminer --version | grep $version)" ]; then
    rm -rf /tmp/ethminer* && mkdir -p /tmp/ethminer
    wget -O /tmp/ethminer.tar.gz https://github.com/ethereum-mining/ethminer/releases/download/v${version}/ethminer-${version}-Linux.tar.gz
    tar -zxf /tmp/ethminer.tar.gz -C /tmp/ethminer --strip-components=1
    cp /tmp/ethminer/ethminer /usr/bin/
    rm -rf /tmp/ethminer*
  fi
}

main()
{
  fn::check_permission
  fn::install_ethminer $@
}

main $@