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

# Usage: fn::instasll_package wget net-tools
fn::install_package()
{
  for package in $@; do
    if ! fn::package_exists $package; then
      yum install -y $package
    fi
  done
}

fn::upgrade_master_components()
{
  if [ -z "$1" ]; then
    echo "You must specify the version you want to upgrade."
    exit 1
  fi

  local new_version=v"$1"
  local old_version=$(kube-apiserver --version | tr -s 'Kubernetes v' 'v')

  fn::install_package wget

  rm -rf /tmp/k8s-server* && mkdir -p /tmp/k8s-server
  wget -O /tmp/k8s-server.tar.gz https://dl.k8s.io/${version}/kubernetes-server-linux-amd64.tar.gz
  tar -zxf /tmp/k8s-server.tar.gz -C /tmp/k8s-server --strip-components=1
  cp -r /tmp/k8s-server/server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl} /usr/bin/
  rm -rf /tmp/k8s-server*
}

fn::restart_master_services()
{
  systemctl restart {kube-apiserver,kube-scheduler,kube-controller-manager}
}

fn::shhow_master_status()
{
  systemctl status kube-apiserver
  systemctl status kube-scheduler
  systemctl status kube-controller-manager
}

main()
{
  fn::check_permission

  fn::upgrade_master_components $@
  fn::restart_master_services
}

# Usage: ./upgrade-k8s-master.sh 1.8.3
main $@