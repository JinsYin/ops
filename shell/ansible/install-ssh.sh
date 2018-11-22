#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>
# 如果原先已经安装了会安装更新的版本

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
  command $1 > /dev/null 2>&1
}

fn::exec_command()
{
  command $@ > /dev/null 2>&1
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

# 支持判断带版本的包是否存在
fn::centos::package_exists()
{
  local package=$1
  [ -n "$package" ] && fn::exec_command rpm -q $package # yum list installed $package
}

# 不支持判断带版本的包是否存在
fn::ubuntu::package_exists()
{
  local package=$1

  if [ -n "$package" ] && [[ "$package" = *"="* ]]; then
    pkg_name=$(echo $package | cut -d '=' -f1)
    pkg_version=$(echo $package | cut -d '=' -f2)

    echo "package: $package"
    echo "pkg_name: $pkg_name"
    echo "pkg_version: $pkg_version"

    fn::exec_command dpkg -s $pkg_name && [ "$(fn::exec_command dpkg -s $pkg_name | grep -E "Status: install ok installed|Version: $pkg_version" | wc -l)" == "2" ]
  else
    [ -n "$package" ] && fn::exec_command dpkg -s $package && fn::exec_command dpkg -s $package | grep 'Status: install ok installed'
  fi
}

# 判断软件包是否存在新版本（参数为包名，可以指定版本）
fn::centos::package_has_a_newer_version()
{
  local package=$1
  [ -n "$package" ] && fn::exec_command yum list available $package # yum check-update
}

# 判断软件包是否存在新版本（参数为包名，不能指定版本）
fn::ubuntu::package_has_a_newer_version()
{
  local package=$1

  # 如果指定了版本，只获取包名
  if [[ "$package" = *"="* ]]; then package=$(echo $package | cut -d '=' -f1); fi

  if [ -n "$package" ] && fn::centos::package_exists $package; then
    current_version=$(dpkg -s $package | grep Version)
    latest_version=$(apt-cache show $package | grep Version | head -1)

    [ "$current_version" != "$latest_version" ]
  else
    return 1
  fi
}

# Usage1: fn::ubuntu::install_package wget ntp
# 不能安装指定的版本
fn::centos::install_package()
{
  for package in $@; do
    # 更新也可以使用 yum update $package
    if ! fn::centos::package_exists $package || fn::centos::package_has_a_newer_version $package; then
      yum install -y $package
    fi
  done
}

# Usage1: fn::ubuntu::install_package wget ntp
# Usage2: fn::ubuntu::install_package wget-1.14-15*
# 如果没有指定软件版本（可以使用 * 进行模糊匹配），默认安装最新版本；如果已经安装了，会安装更新的版本
fn::ubuntu::install_package()
{
  for package in $@; do
    # 更新也可以使用 apt-get install --only-upgrade $package
    if ! fn::ubuntu::package_exists $package || fn::ubuntu::package_has_a_newer_version $package; then
      apt-get install -y $package
    fi
  done
}

fn::install_ansible()
{
  local lsb_dist_name=$(fn::lsb_dist_name)

  case $lsb_dist_name in
    ubuntu)
      fn::ubuntu::install_package openssh-server=1:6.6p1-2ubuntu1*
    ;;
    centos)
      fn::centos::install_package openssh-server-7.4p1-12*
    ;;
  esac
}

main()
{
  fn::check_permission
  fn::install_ansible
}

main $@