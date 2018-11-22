#!/bin/bash
# Author: JinsYin <jinsyin@github.com>

## 一键下载 gcr.io 以及 quay.io　的镜像

##========##
# 下载一个镜像： kubepull gcr.io/google_containers/pause-amd64:3.0
# 下载多个镜像： kubepull gcr.io/google_containers/pause:3.0 gcr.io/google_containers/pause-amd64:3.0
# 从文件中下载： kubepull --from-file=images.txt