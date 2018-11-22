#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>
# 将 lib 目录文件中的定义实现的函数同步更新到其他目录文件中
# Usage1: ./sync-function.sh # 同步更新所有文件中函数
# Usage2: ./sync-function.sh glusterfs/install-glusterfs-server.sh # 同步更新某个文件中的函数

set -e