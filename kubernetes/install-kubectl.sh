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

# kubectl kubefed
fn::install_k8s_client()
{
  local version=v${1:-$K8S_VERSION}
  local components=(kubectl kubefed)
  
  fn::install_package wget

  for component in ${components[@]}; do
    if ! fn::command_exists ${component}; then
      rm -rf /tmp/k8s-client* && mkdir -p /tmp/k8s-client 
      wget -O /tmp/k8s-client.tar.gz https://dl.k8s.io/${version}/kubernetes-client-linux-amd64.tar.gz
      tar -xzf /tmp/k8s-client.tar.gz -C /tmp/k8s-client --strip-components=1
      mv /tmp/k8s-client/client/bin/{kubectl,kubefed} /usr/bin/ && chmod a+x /usr/bin/
      rm -rf /tmp/k8s-client*
    fi
  done  
}

fn::enable_autocompletion()
{
  mkdir -p /etc/bash_completion.d

  echo "source <(kubectl completion bash)" > /etc/bash_completion.d/kubectl.bash

  if [ -z "$(grep '^. /etc/bash_completion.d/kubectl.bash' /etc/bash_completion)" ]; then
    echo ". /etc/bash_completion.d/kubectl.bash" >> /etc/bash_completion
  fi

  if [ -z "$(grep '^. /etc/bash_completion' ~/.bashrc)" ]; then
    echo ". /etc/bash_completion" >> /etc/bash_completion
    source ~/.bashrc
  fi
}

main()
{
  fn::check_permission
  fn::install_k8s_client
  fn::enable_autocompletion
}

main $@