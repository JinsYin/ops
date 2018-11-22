#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

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

# 重复添加会更新
fn::centos::add_repo()
{
  local repo_url=$1
  local repo_basename=${repo_url##*/}

  curl -s -L ${repo_url} -o /etc/yum.repos.d/${repo_basename} > /dev/null
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

fn::ubuntu::install_geth()
{
  fn::ubuntu::install_package software-properties-common
  
  add-apt-repository -y ppa:ethereum/ethereum
  apt-get update
  apt-get install geth
}

fn::install_geth()
{

}

main()
{
  fn::check_permission
}

main $@