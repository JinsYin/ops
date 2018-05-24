#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You need to be root to perform this command."
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

fn::install_common_packages()
{
  local lsb_dist_name=$(fn::lsb_dist_name)

  case $lsb_dist_name in
    ubuntu)
      fn::ubuntu::install_package net-tools dnsutils bridge-utils wget $@
    ;;
    centos)
      fn::centos::install_package epel-release net-tools bind-utils bridge-utils wget $@
    ;;
  esac
}

main()
{
  fn::check_permission
  fn::install_common_packages $@
}

main $@