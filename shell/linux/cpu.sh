#!/bin/bash

# 查看 cpu 个数（几路）
fn::cpu::num()
{
  cat /proc/cpuinfo | grep 'physical id' | sort | uniq | wc -l
}

# 查看 cpu 型号
fn::cpu::model_name()
{
  cat /proc/cpuinfo | grep 'model name' | sort | uniq
}

# 单个 cpu 的核数
fn::cpu::cores()
{
  local single_cores=$(cat /proc/cpuinfo | grep 'cpu cores' | sort | uniq | awk '{print $4}')
  single_cores * fn::cpu::num
}

# 总的 cpu 线程数
fn::cpu::processor()
{
  cat /proc/cpuinfo | grep 'processor' | wc -l
}

fn::cpu::benchmark()
{
  time echo "scale=5000; 4*a(1)" | bc -l -q
}