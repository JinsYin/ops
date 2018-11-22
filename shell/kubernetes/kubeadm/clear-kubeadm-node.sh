#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

fn::clear-node()
{
  kubeadm reset
  rm -rf /etc/kubernetes
}

fn::remove-flannel()
{
  ifconfig cni0 down && ip link delete cni0
  ifconfig flannel.1 down && ip link delete flannel.1
  rm -rf /var/lib/cni/
  rm -rf /etc/cni/net.d/
}

fn::main()
{
  fn::clear-node $@
}

main $@