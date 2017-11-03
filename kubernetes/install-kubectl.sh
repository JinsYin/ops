#!/bin/bash
# Author: JinsYin <jinsyin@github.com>

KUBECTL_VERSION="v1.8.2"

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

fn::install_kubectl_and_kubefed()
{
  local version=${1:-$KUBECTL_VERSION}
  fn::install_package wget

  if ! fn::command_exists kubectl; then
    wget -O /tmp/kubernetes-client.tar.gz https://dl.k8s.io/${version}/kubernetes-client-linux-amd64.tar.gz
    mkdir -p /tmp/kubernetes-client 
    tar -xzf /tmp/kubernetes-client.tar.gz -C /tmp/kubernetes-client --strip-components=1
    mv /tmp/kubernetes-client/client/bin/kube* /usr/bin/ && chmod a+x /usr/bin/kube*
    rm -rf /tmp/kubernetes-client*
  fi
}

main()
{
  fn::check_permission
  fn::install_kubectl_and_kubefed
}

main $@