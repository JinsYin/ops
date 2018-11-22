#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

fn::nameserver-exists()
{
  getent hosts "baidu.com" >> /dev/null
}

fn::add-resolver()
{
  local ns=$1
  if ! fn::nameserver-exists; then
    if [ -n "$ns" ]; then 
      echo "nameserver $ns" >> /etc/resolv.conf
    else
      echo "nameserver 114.114.114.114" >> /etc/resolv.conf
    fi
  fi
}

fn::synchronize-clock()
{
  yum install -y ntp
  ntpdate cn.pool.ntp.org
  hwclock -w # physical machine
  systemctl enable ntpd
  systemctl start ntpd
}