#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

ETCD_DEFAULT_VERSION="v3.1.0"

func::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

func::install_dependencies()
{
  set +e
  wget --version > /dev/null 2>&1
  local wget_code=$?
  set -e

  if [ $wget_code -ne 0 ]; then
    yum install -y wget
  fi
}

func::install_etcd()
{ 
  set +e
  etcd --version > /dev/null 2>&1
  local res_code=$?
  set -e

  if [ $res_code -ne 0 ]; then
    local etcd_version=${1:-$ETCD_DEFAULT_VERSION}
    wget https://github.com/coreos/etcd/releases/download/${etcd_version}/etcd-${etcd_version}-linux-amd64.tar.gz -O /tmp/etcd.tar.gz
    mkdir -p /tmp/etcd && tar xzf /tmp/etcd.tar.gz -C /tmp/etcd --strip-components=1
    mv /tmp/etcd/etcd* /usr/local/sbin && chmod +x /usr/local/sbin/etcd*
    rm -rf /tmp/etcd*
  fi
}

func::config_etcd()
{
  yes | cp -rf /usr/lib/systemd/system/etcd.service{,.bak}
  cat ./etcd.service > /usr/lib/systemd/system/etcd.service

  systemctl daemon-reload
  systemctl restart etcd.service && systemctl enable etcd.service
}

func:deploy_etcd()
{
  echo
}

func::add_member()
{
  etcdctl --endpoints http://172.28.128.100:2379,http://172.28.128.101:2379,172.28.128.102:2379 member add etcd103 http://10.0.1.4:2380
}

func::remove_member()
{
  etcdctl --endpoints http://172.28.128.100:2379,http://172.28.128.101:2379,172.28.128.102:2379 member remove etcd103 http://10.0.1.4:2380
}

func::single_up()
{
  func::install_etcd "v3.1.0"
}

func::multi_up()
{
  echo
}

main()
{
  # ºÏ≤È»®œﬁ
  func::check_permission

  case $1 in
    "install")
      shift
      func::install_dependencies
      func::install_etcd $@
    ;;
    "single") 
      func::single_up $@
    ;;
    "multi") 
      func::multi_up $@
    ;;
    *) 
      echo "usage: $0 [install|single|multi] "
    ;;
  esac
}


main $@