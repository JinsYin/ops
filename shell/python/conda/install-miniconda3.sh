#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

CONDA_VERSION="latest"

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

fn::install_miniconda3()
{
  local version=${1:-$CONDA_VERSION}

  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
}

main()
{
  fn::check_permission
  fn::install_miniconda3 $
}

main $@