#!/bin/bash
# Author: JinsYin <github.com/jinsyin>


https://github.com/Neilpang/acme.sh



# 安装 acme.sh
curl  https://get.acme.sh | sh
echo "alias acme.sh=~/.acme.sh/acme.sh" >> ~/.bashrc

# 自动为你创建 cronjob, 每天 0:00 点自动检测所有的证书, 如果快过期了, 需要更新, 则会自动更新证书.
crontab -l

cd /opt/harbor

# 生成证书
 cd ~/.acme.sh/
apt-get install -y socat
yum install -y socat

# 必须是共有域名，且可以解析
acme.sh --issue -d harbor.services --standalone

ls /root/.acme.sh/harbor.local/

# 复制证书
cd /opt/
mkdir -p /opt/harbor/certs
acme.sh --installcert -d harbor.local --key-file /opt/harbor/certs/harbor.local.key --fullchain-file /opt/harbor/certs/fullchain.cer

# 身份验证
docker run --entrypoint htpasswd registry:2.6 -Bbn kube kube123 > /auth/htpasswd

# 创建仓库
docker run -d \
  --restart=always \
  --name registry \
  -v /auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -v `pwd`/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/fullchain.cer \
  -e REGISTRY_HTTP_TLS_KEY=/certs/hub.ymq.io.key \
  -p 443:443 \
  registry:2.6


docker logs -f registry