#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

set -e

# 为了和 nvidia-docker2 兼容，必须安装稳定版本："17.03.2", "17.06.2", "17.09.0", "17.09.1", "17.12.0"
DOCKER_CE_VERSION="17.06.2"

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

# Usage: fn::remove_package wget net-tools
fn::remove_package()
{
  for package in $@; do
    if fn::package_exists $package; then
      yum remove -y $package
    fi
  done
}

# 重复添加会更新
fn::centos::add_repo()
{
  local repo_url=$1
  local repo_basename=${repo_url##*/}

  curl -s -L ${repo_url} -o /etc/yum.repos.d/${repo_basename} > /dev/null
}

fn::centos::install_docker()
{
  local version=${1:-$DOCKER_CE_VERSION}

  # 移除非官方的 docker 包
  fn::remove_package docker docker-common docker-selinux docker-engine

  # 添加阿里源（官方源：https://download.docker.com/linux/centos/docker-ce.repo）
  fn::centos::add_repo "https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo"

  if fn::package_exists docker-ce-${version}*; then exit 1; fi

  # 安装指定版本
  fn::install_package docker-ce-${version}*
}

fn::centos::create_systemd_unit()
{
cat > /usr/lib/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd \$DOCKER_OPTIONS \$DOCKER_NETWORK_OPTIONS \$DOCKER_STORAGE_OPTIONS
ExecReload=/bin/kill -s HUP \$MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF
}

# 修改 Docker 配置
fn::centos::config_docker()
{
  mkdir -p /usr/lib/systemd/system/docker.service.d

cat > /usr/lib/systemd/system/docker.service.d/docker.conf <<EOF
[Service]
Environment="DOCKER_OPTIONS=--storage-driver=overlay --log-level=error --log-opt max-size=50m --log-opt max-file=5 --exec-opt=native.cgroupdriver=cgroupfs --registry-mirror=https://registry.docker-cn.com"
EOF
}

fn::centos::start_docker()
{
  systemctl daemon-reload
  systemctl enable docker.service
  systemctl restart docker.service
}

# 如果 docker >= 1.13，iptables 的　FORWARD chain　的默认策略是　DROP，会导致无法访问到其他节点的 PodIP
fn::accept_iptables_forward()
{
  fn::install_package iptables
  iptables -P FORWARD ACCEPT
}

fn::enable_bridge_iptables()
{
  sysctl -w net.ipv4.ip_forward=1
  sysctl -w net.bridge.bridge-nf-call-iptables=1
  sysctl -w net.bridge.bridge-nf-call-ip6tables=1
}

main()
{
  fn::check_permission

  fn::centos::install_docker $@
  fn::centos::create_systemd_unit
  fn::centos::config_docker
  fn::centos::start_docker
  
  fn::accept_iptables_forward
  fn::enable_bridge_iptables
}

main $@
