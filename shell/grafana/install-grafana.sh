#!/bin/bash
# Author: JinsYin <github.com/jins>

GRAFANA_VERSION="4.6.3"

# https://grafana.com/grafana/download

fn::install_grafana_bin()
{

}

wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.6.3.linux-x64.tar.gz 
tar -zxvf grafana-4.6.3.linux-x64.tar.gz 