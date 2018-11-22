#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

SPARK_VERSION=2.3.0
HADOOP_VERSION=2.7

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

fn::download_spark()
{
  local spark_version=${1:-$SPARK_VERSION}
  local hadoop_verion=${2:-$HADOOP_VERSION}

  fn::install_package wget

  wget http://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_verion}.tgz

  echo "path:/opt/spark-${spark_version}-bin-hadoop${hadoop_verion}"
  cd /opt/spark-${spark_version}-bin-hadoop${hadoop_verion}

  wget http://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz
}

main()
{
  fn::check_permission
  fn::download_spark $@
}

main $@