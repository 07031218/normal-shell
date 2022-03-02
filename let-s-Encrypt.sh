#!/bin/bash
 
echo "=======================Let's Encrypt环境准备======================================="
if command -v python > /dev/null 2>&1; then
    echo 'python 环境就绪...'
    python_command=python
else
    echo 'python环境不存在，即将开始自动安装。。'
    apt-get -y install python || yum -y install python
    echo 'python 安装成功'
    python_command=python
fi
if command -v openssl > /dev/null 2>&1; then
    echo 'openssl 环境就绪...'
else
    echo 'openssl 不存在，准备安装。。。'
    apt-get -y install openssl || yum -y install openssl
fi
 
echo "==========================环境准备完成==========================="
echo "开始配置"
echo "1、域名配置，请确保你的域名已解析到本机"
echo "请输入域名（多个请用空格隔开）：按回车结束（例：www.baidu.com）"
read -p "> " web_domains
domain_length=0
sign_domain_str=''
web_first_domain=$(echo $web_domains|tr -s [:blank:]|cut -d ' ' -f 1)
nginx_web_config_file=$web_first_domain".conf"
for web_domain in ${web_domains[@]}
do
    sign_domain_str=$sign_domain_str"DNS:"$web_domain","
    domain_length=$(($domain_length+1))
done
sign_domain_str=${sign_domain_str:0:${#sign_domain_str}-1}
echo "$sign_domain_str"
 
echo "2、站点绝对路径配置，如果未输入或者输入非绝对路径，就默认使用域名为目录配置到/tmp目录下"
mkdir /certs
read -p "> " web_dir
if [[ -z "$web_dir" || ! "$web_dir" == /* ]]; then
	web_dir="/certs/"$web_first_domain
fi
 
 
echo -e "\n"
cat << EOF
确认配置
 
网站根目录: $web_dir
域名: $web_domains
 
请输入1或2
1):确认
2):退出
EOF
read -p "> " confirm
if [[  $confirm -eq 2 ]]; then
    exit 0
fi
echo "===========================自动化配置开始================================="
mkdir -p ${web_dir}"/certificate/challenges"
chmod -R 755 ${web_dir}"/certificate"
web_first_parent_dir="/"$(echo $web_dir|cut -d "/" -f2)
find $web_first_parent_dir -type d -exec chmod o+x {} \;
cd $web_dir"/certificate"
echo "Create a Let's Encrypt account private key"
openssl genrsa 4096 > account.key
echo "generate a domain private key"
openssl genrsa 4096 > domain.key
if [[ $domain_length -gt 1 ]]; then
    openssl req -new -sha256 -key domain.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=$sign_domain_str")) > domain.csr || openssl req -new -sha256 -key domain.key -subj "/" -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf "[SAN]\nsubjectAltName=$sign_domain_str")) > domain.csr
else
    openssl req -new -sha256 -key domain.key -subj "/CN=$web_domains" > domain.csr
fi

wget --no-check-certificate https://cdn.jsdelivr.net/gh/diafygi/acme-tiny@master/acme_tiny.py
$python_command acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir $web_dir/certificate/challenges > ./signed.crt || exiterr "create the http website failed,please view the issue of github doc"
#NOTE: For nginx, you need to append the Let's Encrypt intermediate cert to your cert
wget --no-check-certificate  https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem -O intermediate.pem
cat signed.crt intermediate.pem > chained.pem
cp chained.pem $web_domains.crt
cp domain.key $web_domains.key

# current_user=$USER
# current_user=$(id -un) not work for sudo
current_user=$(who am i|awk '{print $1}')
current_user_group=$(id -gn $current_user)
chown -R $current_user:$current_user_group $web_dir
chmod -R 755 $web_dir
echo -e "\n\n"
cat << EOF
域名证书申请完毕，证书目录 ${web_dir}/certificate
EOF
cat > $web_dir/certificate/renew_cert.bash <<EOF
cd $web_dir/certificate
wget --no-check-certificate https://cdn.jsdelivr.net/gh/diafygi/acme-tiny@master/acme_tiny.py -O acme_tiny.py
$python_command ./acme_tiny.py --account-key ./account.key --csr ./domain.csr --acme-dir $web_dir/certificate/challenges/ > /tmp/signed.crt || exit
wget --no-check-certificate -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem
cat /tmp/signed.crt intermediate.pem > $web_dir/certificate/chained.pem
cp $web_dir/certificate/chained.pem $web_dir/certificate/$web_domains.crt
EOF
 
echo "Let's Encrypt 证书有效期定时任务配置"
if command -v crontab > /dev/null 2>&1; then
    echo 'crontab 已安装'
else
    echo 'crontab 未安装，将为您自动安装...'
    apt-get -y install cron || yum -y install cron
fi
echo "1 1 1 * * root bash $web_dir/certificate/renew_cert.bash >> /var/log/renew_cert_error.log 2 >> /var/log/renew_cert.log" >> /etc/crontab
echo "证书续期定时器添加成功"
exit 0
