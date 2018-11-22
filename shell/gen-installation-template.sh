#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>
# 在当前目录下生成安装模板
# 安装原则：
#   - 如果软件包存在
#     - 如果没有被安装
#       - 如果指定了版本，则安装相应版本
#       - 如果没有指定版本，则安装最新版本
#     - 如果已经被安装，则检测是否有更新
#       - 如果有，则更新
#       - 如果无，则不做任何操作
#   - 如果软件包不存在或为空，则不做任何操作

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

fn::install_demo()
{
  echo ""
}

main()
{
  fn::check_permission
  fn::install_demo $@
}

main $@