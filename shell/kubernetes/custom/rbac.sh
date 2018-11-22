#!/bin/bash
# Author: JinsYin <jinsyin@github.com>

# 查看所有的 subject 以及其绑定的 role 或者 clusterrole
fn::rolebinding::all-subjects()
{
  kubectl get rolebinding --all-namespaces -o yaml | grep "subjects" -A 3 -B 4 | grep "name: " -A 1 -B 5
}

fn::rolebinding::get()
{
  local subject=$1
  kubectl get rolebinding --all-namespaces -o yaml | grep "subjects" -A 3 -B 4 | grep "name: ${subject}" -A 1 -B 5
}