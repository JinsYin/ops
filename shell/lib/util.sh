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

# https://github.com/feiskyer/ops/blob/master/kubernetes/lib/util.sh
fn::command_exists() 
{
  command -v "$@" > /dev/null 2>&1
}

fn::package_exists()
{
  rpm -q $@ > /dev/null 2>&1
}

# e.g. fn::instasll_package wget net-tools
fn::install_package()
{
  for package in $@; do
    if ! fn::package_exists $package; then
      yum install -y $package
    fi
  done
}

fn::lsb-dist() 
{
  local lsb_dist=''
  
  if command_exists lsb_release; then
      lsb_dist="$(lsb_release -si)"
  fi
  if [ -z "$lsb_dist" ] && [ -r /etc/lsb-release ]; then
      lsb_dist="$(. /etc/lsb-release && echo "$DISTRIB_ID")"
  fi
  if [ -z "$lsb_dist" ] && [ -r /etc/centos-release ]; then
      lsb_dist='centos'
  fi
  if [ -z "$lsb_dist" ] && [ -r /etc/redhat-release ]; then
      lsb_dist='redhat'
  fi
  if [ -z "$lsb_dist" ] && [ -r /etc/os-release ]; then
      lsb_dist="$(. /etc/os-release && echo "$ID")"
  fi

  lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
  echo ${lsb_dist}
}

# 重复添加会更新
fn::centos::add_repo()
{
  local repo_url=$1
  local repo_basename=${repo_url##*/}

  curl -s -L ${repo_url} -o /etc/yum.repos.d/${repo_basename} > /dev/null
}

# 判断数组中是否存在某个元素
fn::array::contains()
{
  array=$1
  elem=$2

  [[ ${array[*]} =~ $elem ]]
}