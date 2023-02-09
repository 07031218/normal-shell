#!/bin/bash
check_dependencies(){

  os_detail=$(cat /etc/os-release 2> /dev/null)
  if_debian=$(echo $os_detail | grep 'ebian')
  if_redhat=$(echo $os_detail | grep 'rhel')
  if [ -n "$if_debian" ];then
    InstallMethod="apt-get"
  elif [ -n "$if_redhat" ] && [[ "$os_version" -lt 8 ]];then
    InstallMethod="yum"
  fi
}
check_dependencies
$InstallMethod update > /dev/null
$InstallMethod install curl -y > /dev/null
echo '============================
      SSH Key Installer
        V1.0
    Author:翔翎
============================'
cd ~
if [[ ! -d .ssh ]]; then
  mkdir .ssh
fi
cd .ssh
read -p "请输入公钥内容(注意，公钥内容千万别漏字也别多字，也千万不要错把私钥内容复制上来了！)：" keywords
echo "$keywords" >authorized_keys
chmod 700 authorized_keys
cd ../
chmod 600 .ssh
cd /etc/ssh/

sed -i "/PasswordAuthentication no/c PasswordAuthentication no" sshd_config
sed -i "/RSAAuthentication no/c RSAAuthentication yes" sshd_config
sed -i "/PubkeyAuthentication no/c PubkeyAuthentication yes" sshd_config
sed -i "/PasswordAuthentication yes/c PasswordAuthentication no" sshd_config
sed -i "/RSAAuthentication yes/c RSAAuthentication yes" sshd_config
sed -i "/PubkeyAuthentication yes/c PubkeyAuthentication yes" sshd_config
service sshd restart
service ssh restart
echo "启用密钥登录完成，密码登录已失效，后续请用对应私钥登录小鸡。"
