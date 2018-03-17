set -e

echo "Installing Ansible..."

cat <<EOF > /etc/yum.repos.d/epel.repo 
[EPEL]
name=EPEL
baseurl=http://download.fedoraproject.org/pub/epel/\$releasever/\$basearch/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF

yum install -y ansible

# https://github.com/markthink/kubernetes1.4/blob/master/scripts/bootstrap_ansible_centos.sh