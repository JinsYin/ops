#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

images_v16_components()
{
  local version=$1
  images=(
    "kube-controller-manager-amd64:v${version}"
    "kube-apiserver-amd64:v${version}"
    "kube-proxy-amd64:v${version}"
    "kube-scheduler-amd64:v${version}"
    "etcd-amd64:3.0.17"
    "pause-amd64:3.0"
    "k8s-dns-sidecar-amd64:1.14.1"
    "k8s-dns-sidecar-amd64:1.14.1"
    "k8s-dns-dnsmasq-nanny-amd64:1.14.1"
    "flannel:v0.7.1-amd64"
  )
}

pull_v162_images()
{
  local version="v1.6.2"
  local images=(
    "gcr.io/google_containers/etcd-amd64:3.0.17"
    "gcr.io/google_containers/kube-controller-manager-amd64:$version"
    "gcr.io/google_containers/kube-apiserver-amd64:$version"
    "gcr.io/google_containers/kube-scheduler-amd64:$version"
    "gcr.io/google_containers/kube-proxy-amd64:$version"
    "gcr.io/google_containers/pause-amd64:3.0"
    "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.1"
    "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.1"
    "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.1"
    "quay.io/coreos/flannel:v0.7.1-amd64"
  )

  for image in ${images[@]}; do
    if ! fn::image_exists $image; then
      docker pull dockerce/$image
    fi

    if [ -n "$(fn::image_match $image 'gcr.io/google_containers')" ]; then
      docker tag dockerce/$image gcr.io/google_containers/$image
    elif [ -n "$(fn::image_match $image 'quay.io/coreos')" ]
      docker tag dockerce/$image quay.io/coreos/$image
    fi
    # docker rmi dockerce/$image:$tag
  done
}

fn::kubeadm-master-v1.6()
{
  fn::install-docker-centos "1.12.6"
}

fn::image_match()
{
  local image_name=$1
  lcoal match_value=$2
  echo $image_name | grep -Eo ".*${match_value}.*"
}

fn::command_exists() {
  command -v "$@" > /dev/null 2>&1
}

fn::image_exists()
{
  local image_name=$1
  local image_tag=$2

  if fn::command_exists docker images; then
    match_result=$(docker images | grep $image_name | grep $image_tag)
    echo ${match_result}
  fi
}

fn::get_images()
{
  local tag=$1

  for image in ${images[@]}; do
    if ! fn::image_exists $image; then
      docker pull dockerce/$image
    fi

    if [ -z "$(fn::match_coreos $image)" ]; then
      docker tag dockerce/$image gcr.io/google_containers/$image
    else
      docker tag dockerce/$image quay.io/coreos/flannel
    fi
    # docker rmi dockerce/$image:$tag
  done
}

fn::centos::install-kubeadm()
{
  echo ""
}

fn::centos::remove-kubeadm()
{
  yum remove -y kubectl kubelet kubeadm kubernetes-cni
}

main()
{
  case $1 in
    1.6.*)
      shift
      fn::get_images $@
    ;;
    *)
      echo "Usage: ${0} <kubenetes-version>"
      echo "Example: ./kube-installation.sh 1.6.2"
    ;;
  esac
}

main $@