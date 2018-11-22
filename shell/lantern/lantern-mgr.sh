#!/bin/bash
# Author: JinsYin <github.com/jinsyin>

fn::rm-proxy()
{
  unset $(env | grep -i "proxy" | awk -F "=" '{print $1}')
}