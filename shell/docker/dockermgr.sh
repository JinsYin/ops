#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

DOCKER_DEFAULT_VERSION="1.12.6"

DOCKER_ROOT=$(dirname "${BASH_SOURCE}")
source ${DOCKER_ROOT}/../lib/util.sh

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

fn::install_docker_centos()
{
  if fn::command_exists docker; then
    exit 0
  fi

  local docker_version=${1:-$DOCKER_DEFAULT_VERSION}

  # �Ƴ��ǹٷ��� docker ��
  yum remove -y docker docker-common container-selinux docker-selinux

  # yum-config-manager
  yum install -y yum-utils

  # ����ȶ��Ĺٷ�Դ
  yum-config-manager --add-repo https://docs.docker.com/v1.13/engine/installation/linux/repo_files/centos/docker.repo

  # ���°�����
  yum makecache fast

  # ��װָ���汾��docker-engine-selinux �� docker-engine ���������������Ȱ�װ��ָ����ͬ�İ汾��
  yum install -y docker-engine-selinux-${docker_version}* docker-engine-${docker_version}*
}

fn::centos::install-docker()
{
  echo ""
}

fn::ubuntu::install-docker()
{
  echo ""
}

fn::centos::config-docker()
{
  echo ""
}

fn::ubuntu::config-docker()
{
  echo ""
}

fn::config_docker()
{
  yes | cp -rf /usr/lib/systemd/system/docker.service{,.bak}
  cat ../yum.repos.d/docker/docker.service > /usr/lib/systemd/system/docker.service

  systemctl daemon-reload
  systemctl enable docker.service && systemctl restart docker.service
}

fn::remove_docker()
{
  # �Ƴ��ǹٷ��� docker ��
  yum remove -y docker docker-common container-selinux docker-selinux

  # �Ƴ��ٷ��� docker ��
  yum remove -y docker-engine-selinux docker-engine
}

fn::purge_docker()
{
  fn::remove_docker
  rm -rf /var/lib/docker
}

main(){
  # ���Ȩ��
  fn::check_permission

  case $1 in
    "install")
      shift
      fn::install_docker_centos $@
      fn::config_docker
    ;;
    "remove")
      fn::remove_docker
    ;;
    "purge")
      fn::purge_docker
    ;;
    *)
      echo "usage: $0 [install <version>|remove|purge]"
      echo "example: ./docker.sh --os-type=centos install 1.12.6"
    ;;
  esac
}

main $@