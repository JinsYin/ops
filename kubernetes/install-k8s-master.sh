#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

set -e

K8S_VERSION="1.8.2"

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

fn::install_k8s_master()
{
  local version=v${1:-$K8S_VERSION}
  local components=(kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy kubectl)

  fn::install_package wget

  for component in ${components[@]}; do
    if ! fn::command_exists ${component}; then
      rm -rf /tmp/k8s-server* && mkdir -p /tmp/k8s-server
      wget -O /tmp/k8s-server.tar.gz https://dl.k8s.io/${version}/kubernetes-server-linux-amd64.tar.gz
      tar -zxf /tmp/k8s-server.tar.gz -C /tmp/k8s-server --strip-components=1
      cp -r /tmp/k8s-server/server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubelet,kube-proxy,kubectl} /usr/bin/
      rm -rf /tmp/k8s-server*
    fi
  done
}

main()
{
  fn::check_permission
  fn::install_k8s_master $@
}

main $@