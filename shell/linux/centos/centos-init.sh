#!/bin/bash

fn::disable_selinux()
{
    setenforce 0
    sed -i "s|SELINUX=enforcing|SELINUX=disabled|g" /etc/selinux/config
}

fn::disable_firewall()
{
    systemctl stop firewalld
    systemctl disable firewalld
}

fn::sync_clock()
{
    yum install -y ntp
    ntpdate cn.pool.ntp.org
    hwclock -w
    systemctl enable ntpd
    systemctl restart ntpd
}

fn::install_dep()
{
    yum install -y {epel-release, git, net-tools, pciutils}
}