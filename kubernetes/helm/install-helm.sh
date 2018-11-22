#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

set -e

HELM_VERSION="v2.8.0"

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

fn::package_exists()
{
  rpm -q $@ > /dev/null 2>&1
}

# Usage: fn::instasll_package wget net-tools
fn::install_package()
{
  for package in $@; do
    if ! fn::package_exists $package; then
      yum install -y $package
    fi
  done
}

fn::install_helm()
{
  local version=${1:-$HELM_VERSION}

  fn::install_package wget

  if ! fn::command_exists helm; then
    rm -rf /tmp/helm* && mkdir -p /tmp/helm
    wget -O /tmp/helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-${version}-linux-amd64.tar.gz
    tar -zxvf /tmp/helm.tar.gz -C /tmp/helm --strip-components=1
    mv /tmp/helm/helm /usr/local/bin/ && chmod +x /usr/local/bin/helm
    rm -rf /tmp/helm*
  fi
}

main()
{
  fn::check_permission
  fn::install_helm $@
}

main $@
