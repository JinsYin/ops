#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

set -e

DOCKER_ROOT=$(dirname "${BASH_SOURCE}")
source ${DOCKER_ROOT}/../util.sh

fn::image_exists()
{
  local image_name=$1
  local image_tag=$2

  if fn::command_exists docker images; then
    match_result=$(docker images | grep $image_name | grep $image_tag)
    echo ${match_result}
  fi
}

fn::remove_all_images()
{
  echo ""
}

fn::remove_image()
{
  local image_name=$1
}

fn::rm_all_none_images()
{
  local none_images=$(docker images | grep -i none | awk '{print $3}')
  for none_image in $none_images; do
    docker rmi $none_image --force
  done
}

fn::rm_all_exited_containers()
{
  local exited_containers=$(docker ps -a | grep -i exited | awk '{print $1}')
  for exited_container in $exited_containers; do
    docker rm $exited_container --force
  done
}