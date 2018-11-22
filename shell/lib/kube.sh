#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

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