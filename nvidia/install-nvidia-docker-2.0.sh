#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

DOCKER_VERSION="17.06.2"
NV_DOCKER_VERSION="2.0.2"

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

# Usage: fn::install_package wget net-tools
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

fn::centos::install_nvidia_docker2()
{
  local docker_version=${1:-DOCKER_VERSION}
  local nv_docker_version=${2:-NV_DOCKER_VERSION}

  # 如果安装了 1.0，需要卸载并移除所有正在运行的 GPU 容器
  docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
  fn::remove_package nvidia-docker

  fn::centos::add_repo https://nvidia.github.io/nvidia-docker/centos7/x86_64/nvidia-docker.repo

  if fn::package_exists nvidia-docker2-${nv_docker_version}-1.docker${docker_version}*; then exit 1; fi

  # 依赖项: nvidia-container-runtime
  fn::install_package nvidia-docker2-${nv_docker_version}-1.docker${docker_version}*

  # 重新加载 Docker daemon 配置
  pkill -SIGHUP dockerd
}

# nvidia-container-runtime 作为默认运行时
fn::centos::config_docker()
{
  mkdir -p /usr/lib/systemd/system/docker.service.d

cat > /usr/lib/systemd/system/docker.service.d/docker.conf <<EOF
[Service]
Environment="DOCKER_OPTIONS=--default-runtime=nvidia --storage-driver=overlay --log-level=error --log-opt max-size=50m --log-opt max-file=5 --exec-opt=native.cgroupdriver=cgroupfs"
EOF
}

fn::centos::restart_docker()
{
  systemctl daemon-reload
  systemctl restart docker.service
}

main()
{
  fn::check_permission
  fn::centos::install_nvidia_docker2 $@

  fn::centos::config_docker
  fn::centos::restart_docker

  # Check docker info
  # docker info

  # Test nvidia-smi
  # docker run --runtime=nvidia --rm nvidia/cuda:9.0-devel nvidia-smi
}

main $@
