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

fn::add_kubernetes_repo()
{
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
}

fn::install_kubeadm_master()
{
  local version=${1:-$K8S_VERSION}
  local components=(kubeadm kubectl)

  fn::add_kubernetes_repo

  for component in ${components[@]}; do
    if ! fn::command_exists ${component}; then
      yum install -y ${component}-${version}
    fi
  done
}

main()
{
  fn::check_permission
  fn::install_kubeadm_master $@
}

main $@
