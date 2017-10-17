#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

fn::remove-all-units()
{
  systemctl list-units | grep ceph
}

fn::show-all-units()
{
  systemctl status ceph\*.service ceph\*.target
}

fn::remove-failed-units()
{
  local failed_units=$(systemctl --failed | grep ceph | awk '{print $2}')
  for unit in ${failed_units[@]}; do
    echo $unit
    systemctl stop "${unit}"
    systemctl disable "${unit}"
    systemctl daemon-reload
    systemctl reset-failed
  done
}

fn::mon::remove()
{
  local mon_id=$1
  ceph mon remove ${mon_id}
}

fn::mon::remove-by-deploy()
{
  local mon_host=$1
  ceph-deploy mon destroy ${mon_host}
}

fn::mon::add()
{
  local mon_id=$1
  mkdir /var/lib/ceph/mon/ceph-${mon_id}
}

fn::mon::add-by-deploy()
{
  local mon_host=$1
  ceph-deploy mon create $mon_host
}

# 在需要移除 ceph 的节点上
fn::osd::remove()
{
  local osd_id=$1
  local ceph_name=${2:-"ceph"}
  ceph osd out ${osd_id}
  ceph osd crush remove ${osd_id}
  ceph auth del osd.${osd_id}
  ceph osd rm ${osd_id}
  umount /var/lib/ceph/osd/${ceph_name}-${osd_id}
}

fn::osd::add-by-deploy()
{
  echo
}

fn::osd::show-by-deploy()
{
  local osd_host=$1
  ceph-deploy disk list ${osd_host}
}

fn::osd::zap-by-deploy()
{
  local osd_host=$1
  local osd_device=$2
  ceph-deploy disk zap ${osd_host}:${osd_device}
}

fn::osd::list-disk-by-deploy()
{
  local osd_host=$1
  ceph-deploy disk list ${osd_host}
}

fn::osd::prepare-by-deploy()
{
  local osd_host=$1
  local osd_data_dev=$2
  local osd_jounal_dev=$3
  ceph-deploy osd prepare ${osd_host}:${osd_data_dev}:${osd_jounal_dev}
}

fn::manager::add-admin()
{
  local node_name=$1
  ceph-deploy add ${node_name}
}

fn::rgw:install()
{
  local gw_host=$@
  ceph-deploy install -rgw ${gw_host}
}

fn::rgw::create()
{
  local gw_host=$@
  ceph-deploy rgw create ${gw_host}
}

fn::rgw::install()
{
  local rgw_host=$@
  ceph-deploy install --rgw ${rgw_host}
}

fn::rgw:create()
{
  local rgw_host=$@
  ceph-deploy rgw create ${rgw_host}
}

fn::df()
{
  ceph df
}

fn::df-tree()
{
  ceph osd df tree
}