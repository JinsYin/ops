#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

PYTHON_VERSION="3.5.2"

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

fn::centos::install_python()
{
  local version=${1:-$PYTHON_VERSION}

  fn::install_package gcc wget

  cd /tmp && wget https://www.python.org/ftp/python/${version}/Python-${version}.tgz
  tar -zxvf /tmp/Python-${version}.tgz
  mv /tmp/Python-${version} /usr/share/python${version}

  cd /usr/share/python${version}
  ./configure
  make
  make test
  sudo make install
}