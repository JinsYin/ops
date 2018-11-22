#!/bin/bash
# Author: JinsYin <github.com>
# https://github.com/ceph/ceph-container/blob/master/ceph-releases/jewel/centos/7/base/Dockerfile
# http://lists.ceph.com/pipermail/ceph-users-ceph.com/2017-July/019503.html
# Usage: ./install-ceph.sh jewel 10.2.9

set -e

CEPH_RELEASE="jewel"
CEPH_VERSION="10.2.9"

fn::check_permission()
{
  if [ $(id -u) -ne 0 ]; then
    echo "You must run as root user or through the sudo command."
    exit 1
  fi
}

fn::command_exists()
{
  command -v "$@" > /dev/null 2>&1
}

fn::package_exists()
{
  rpm -q $@ > /dev/null 2>&1
}

# Usage: fn::install_package wget net-tools
fn::install_package()
{
  for package in $@; do
    if ! fn::package_exists $package; then
      yum install -y $package
    fi
  done
}

# 这里不使用上面的函数是因为非常容易出错
fn::install_ceph()
{
  local release=${1:-$CEPH_RELEASE}
  local version=${2:-$CEPH_VERSION}

  # Install epel-release
  yum install -y yum-utils \
  && yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ \
  && yum install --nogpgcheck -y epel-release \
  && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 \
  && rm -f /etc/yum.repos.d/dl.fedoraproject.org*

  # Install ceph-release
  rpm --import 'https://download.ceph.com/keys/release.asc'
  rpm -Uvh http://download.ceph.com/rpm-${release}/el7/noarch/ceph-release-1-1.el7.noarch.rpm

  # Install ceph-common
  yum install -y ceph-common-${version} libradosstriper1-${version} librgw2-${version}

  # Install ceph-base and ceph-selinux
  yum install -y ceph-base-${version} ceph-selinux-${version}

  # Install ceph components
  yum install -y ceph-${version} \
    ceph-mon-${version} \
    ceph-osd-${version} \
    ceph-mds-${version} \
    ceph-radosgw-${version} \
    rbd-mirror-${version}
}

main()
{
  fn::check_permission
  fn::install_ceph $@
}

main $@