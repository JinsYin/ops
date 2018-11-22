#!/bin/bash
# Author: JinsYin <github.com/jinsyin>
# Kubernetes ctl(kc)

fn::whoami()
{

}

# kc login -u system:admin
fn::login()
{

}

fn::status()
{

}

# kc version
# kc-version kubectl-version apiserver-version
fn::version()
{

}

# kc node
# kc node name
# kc node status
# kc node ip
fn::node()
{
  local names=$(kubectl get nodes -o jsonpath='{range.items[*].metadata}{.name} {end}')
  local ips=$(kubectl get nodes -o jsonpath='{range .items[*].status.addresses[?(@.type=="InternalIP")]}{.address} {end}')
}

# kc exec -it pod/nginx-111 -- sh
# kc exec -it deploy/nginx -- sh （默认进入第一个 Pod）
fn::exec()
{

}

# kc get template (helm)
fn::template()
{

}

# kc images
fn::images()
{

}

fn::ps()
{

}

# kc adm
fn::adm()
{

}

main()
{
  case $1 in
    "version")
      shift
      fn::version $@
    "whoami")
      shift
      fn::whoami $@ 
    ;;
    "login")
      shift
      fn::whoami $@
    "status")
      shift
      fn::status $@
    ;;
    "-h"|"--help")
      shift
      fn::help $@
    *)
      kubectl $@
    ;;
  esac
}

main $@


---

#!/usr/bin/env bash
# 功能: 切换context
#
# /usr/loca/bin/kkc maotai
# 1. 如果不存在,则创建了namespace:maotai 并 切换context 到 maotai
# 2,如果context存在,则切换之

# /usr/loca/bin/kkc
# 1,切换context到default

# 脚本参数说明:
# 共有1个参数,且这个参数必须是字母+数字,长度为4-6位
# 如果超过1个参数,或者参数不符合规定,则设置为default-context.
set -eu

if [ ${#} -eq 1 ] && [[ ${1} =~ (^[a-zA-Z0-9]{4,6}$) ]];then
    if [ -z `kubectl config get-contexts|egrep "${1}-ctx|${1}"` ];then
        kubectl create ns ${1}
        kubectl config set-context ${1}-ctx --namespace=$1 --cluster=local-server
        kubectl config use-context ${1}-ctx
    else
        kubectl config use-context ${1}-ctx
    fi
else
    kubectl config use-context default-context
fi
kubectl config get-contexts


---

source <(helm completion bash)
source <(kubectl completion bash)

kubens()
{ 
 kubectl config set-context $(kubectl config current-context) --namespace=${1:-default}; echo "current namespace ${1:-default}"; 
}  

kubens -> default  kubens kube-system  -> kube-system 我这样用的

---

Pod 里面获取其他 Pod 的 name

kubectl -s kube-apiserver-http.kube-public -n kube-public get pods -l name=spring -o name | cut -d"/" -f2

nodes=$(kubectl get nodes -o jsonpath='{range.items[*].metadata}{.name} {end}')

fn::node_names()
{
  local names=$(kubectl get nodes -o jsonpath='{range.items[*].metadata}{.name} {end}')
  echo $names
}

fn::nodes_ip()
{
  local ips=$(kubectl get nodes -o jsonpath='{range .items[*].status.addresses[?(@.type=="ExternalIP")]}{.address} {end}')
  echo $ips
}

fn::pod_ip()
{
  local hostname=$1
  kubectl describe pod ${hostname} | grep IP | sed -E 's/IP:[[:space:]]+//'
}