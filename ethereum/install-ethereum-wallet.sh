#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>
# 仅限 Linux 桌面版安装

set -e

WALLET_VERSION="0.9.3"

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

fn::install_ethereum_wallet()
{
  local version=${1:-$WALLET_VERSION}
  local version2=$(echo $version | sed -e "s|\.|-|g")

  fn::install_package wget unzip

  if ! fn::command_exists ethereumwallet || [ -z "$(ethereumwallet --version | grep $version)" ]; then
    rm -rf /tmp/ethereumwallet* && mkdir -p {/tmp/ethereumwallet,/usr/local/ethereumwallet}
    wget -O /tmp/ethereumwallet.tar.gz https://github.com/ethereum/mist/releases/download/v${version}/Ethereum-Wallet-linux64-${version2}.zip
    unzip /tmp/ethereumwallet.tar.gz -d /tmp/ethereumwallet
    cp -rf /tmp/ethereumwallet/linux-unpacked/* /usr/local/ethereumwallet/
    rm -rf /tmp/ethereumwallet*

    rm -f /usr/bin/ethereumwallet && ln -s /usr/local/ethereumwallet/ethereumwallet /usr/bin/ethereumwallet
  fi
}

main()
{
  fn::check_permission
  fn::install_ethereum_wallet $@
}

main $@