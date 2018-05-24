#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

NVIDIA_DOCKER_VERSION="1.0.1"

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

# 重复添加会更新
fn::centos::add_repo()
{
  local repo_url=$1
  local repo_url_base=${repo_url##*/}

  fn::install_package curl
  curl -s -L ${repo_url} -o /etc/yum.repos.d/${repo_url_base} > /dev/null
}

fn::ubuntu::add_repo()
{
  local repo_url=$1
  local repo_url_base=${repo_url##*/}

  fn::install_package curl
  curl -sL $repo_url -o /
}

fn::ubuntu::install_deb()
{
  local repo_url=$1
  local repo_url_base=${repo_url##*/}

  fn::ubuntu::install_package wget
  wget -O 
}

fn::centos::install_nvidia_docker1x()
{
  local version=${1:-$NVIDIA_DOCKER_VERSION}

  # 添加源
  fn::centos::add_repo https://nvidia.github.io/nvidia-docker/centos7/x86_64/nvidia-docker.repo

  if fn::centos::package_exists nvidia-docker-${version}*; then exit 1; fi

  fn::centos::install_package nvidia-docker-${version}*
}

fn::centos::start_nvidia_docker()
{
  systemctl enable nvidia-docker
  systemctl start nvidia-docker
  # journalctl -f -u nvidia-docker
}

# Install nvidia-docker and nvidia-docker-plugin
fn::ubuntu::install_nvidia_docker1x()
{
  local version=${1:-$NVIDIA_DOCKER_VERSION}

  wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
  dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb

  # Test nvidia-smi
  nvidia-docker run --rm nvidia/cuda nvidia-smi
}

fn::install_nvidia_docker1x()
{
  local lsb_dist_name=$(fn::lsb_dist_name)

  case $lsb_dist_name in
    ubuntu)
      fn::ubuntu::install_nvidia_docker1x $@
    ;;
    centos)
      fn::centos::install_nvidia_docker1x $@
    ;;
  esac
}

fn::test_nvidia_smi()
{
  # Test nvidia-smi
  nvidia run --rm nvidia/cuda:latest nvidia-smi
}

main()
{
  fn::check_permission
  fn::install_nvidia_docker $@


  fn::centos::install_nvidia_docker $@
  fn::centos::start_nvidia_docker

  
  # nvidia-docker run --rm nvidia/cuda:9.0-devel nvidia-smi
}

main $@
