#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

set -e

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
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

fn::upgrade_node_components()
{
  if [ -z "$1" ]; then
    echo "You must specify the version you want to upgrade."
    exit 1
  fi

  local new_version=v"$1"

  fn::install_package wget

  rm -rf /tmp/k8s-server* && mkdir -p /tmp/k8s-server
  wget -O /tmp/k8s-server.tar.gz https://dl.k8s.io/${version}/kubernetes-server-linux-amd64.tar.gz
  tar -zxf /tmp/k8s-server.tar.gz -C /tmp/k8s-server --strip-components=1
  cp -r /tmp/k8s-server/server/bin/{kube-proxy,kubelet} /usr/bin/
  rm -rf /tmp/k8s-server*
}

fn::restart_node_services()
{
  systemctl start {kube-proxy,kubelet}
}

fn::Node_status()
{
  systemctl status kubelet
  systemctl status kube-proxy
}

main()
{
  fn::check_permission

  fn::upgrade_node_components $@
  fn::restart_node_services
}

# Usage: ./upgrade-k8s-node.sh 1.8.3
main $@