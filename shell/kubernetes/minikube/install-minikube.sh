#!/bin/bash
# Author: JinsYin <jinsyin@github.com>

set -e

MINIKUBE_VERSION="latest"
KUBECTL_VERSION="stable"

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

fn::install_minikube()
{
  local minikube_version=${1:-$MINIKUBE_VERSION}
  local kubectl_version=${2:-$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)}

  if ! command_exists minikube; then
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/${minikube_version}/minikube-linux-amd64
    chmod +x minikube && mv minikube /usr/local/bin/
  fi

  if ! command_exists kubectl; then
    curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/amd64/kubectl
    chmod +x kubectl && mv kubectl /usr/local/bin/
  fi
}

main()
{
  fn::check_permission
  fn::install_minikube $@
}

main $@