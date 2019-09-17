#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

KUBE_APISERVER="https://127.0.0.1:6443"
KUBE_PKI_PATH="/etc/kubernetes/pki"
KUBE_CONFIG_FILE="~/.kube/config"
KUBE_CLUSTER="kubernetes"
CLIENT_USER="admin"
CLIENT_NAMESPACE="default"

fn::set-cluster()
{
  local cluster=${1:-$KUBE_CLUSTER}

  kubectl config set-cluster ${cluster} \
  --certificate-authority=${KUBE_PKI_PATH}/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --KUBE_CONFIG_FILE=${KUBE_CONFIG_FILE}
}

fn::set-credentials()
{
  local cluster=${1:-$KUBE_CLUSTER}
  local user=${2:-$CLIENT_USER}

  kubectl config set-credentials ${user}@${cluster} \
  --client-certificate=${KUBE_PKI_PATH}/${user}.pem \
  --client-key=${KUBE_PKI_PATH}/${user}-key.pem \
  --embed-certs=true \
  --KUBE_CONFIG_FILE=${KUBE_CONFIG_FILE}
}

fn::set-context()
{
  local cluster=${1:-$KUBE_CLUSTER}
  local namespace=${2:-$CLIENT_NAMESPACE}
  local user=${3:-$CLIENT_USER}

  kubectl config set-context ${user}@${cluster}:${namespace} \
  --cluster=${cluster} \
  --namespace=${namespace} \
  --user=${user}@${cluster} \
  --KUBE_CONFIG_FILE=${KUBE_CONFIG_FILE}
}

fn::use_context()
{
  kubectl config use-context ${namespace}:${user}@${cluster}
}

fn::KUBE_CONFIG_FILE()
{
  cp ~/.kube/config ~/.kube/config.bak

}

# Usage: ./kubeconfig.sh --apiserver=https://xxx:6443 --cluster kubernetes --namespace=dev --user=xiaoming
main()
{

}

main $@