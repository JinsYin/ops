#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

fn::ui::create-dashboard()
{
  kubectl create -f https://git.io/kube-dashboard
}

fn::ui::create-heapster()
{
  
}

fn::network::create-flannel()
{

}

fn::network::create-calico()
{

}

fn::network::create-weave()
{

}

