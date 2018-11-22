#!/bin/bash
# Author: JinsYin <jinsyin@gmail.com>

yum -y install nfs-utils ,rpcbind

一定要先启动rpc，然后启动nfs
nfs需要向rpc注册，rpc一旦重启，所以注册的文件都丢失，其他向注册的服务都需要重启

vi /etc/fstab

server_ip:/export/primary/mnt/primary nfs rw,tcp,intr 0 1

server_ip:/export/secondary/mnt/secondary nfs rw,tcp,intr 0 1