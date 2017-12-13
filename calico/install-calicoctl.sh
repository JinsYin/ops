#!/bin/bash
# Author: JinsYin <jinsyin@github.com>

set -e

CALICOCTL_VERSION="1.6.1"

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

fn::command_exists() {
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

fn::install_calicoctl()
{
  local version=v${1:-$CALICOCTL_VERSION}

  fn::install_package wget

  if ! fn::command_exists calicoctl; then
    wget -O /usr/bin/calicoctl https://github.com/projectcalico/calicoctl/releases/download/${version}/calicoctl
    chmod +x /usr/bin/calicoctl
  fi
}

fn::config_calicoctl()
{
  local etcd_endpoints=${1:-"https://127.0.0.1:2379"}
  mkdir -p /etc/calico

cat <<EOF > /etc/calico/calicoctl.cfg
apiVersion: v1
kind: calicoApiConfig
metadata:
spec:
  datastoreType: "etcdv2"
  etcdEndpoints: "${etcd_endpoints}"
  etcdKeyFile: "/etc/etcd/pki/etcd-key.pem"
  etcdCertFile: "/etc/etcd/pki/etcd.pem"
  etcdCACertFile: "/etc/etcd/pki/ca.pem"
EOF
}

fn::calico_status()
{
  calicoctl node status
}

main()
{
  fn::check_permission
  fn::install_calicoctl $@
}

main $@
