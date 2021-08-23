yum install bind-utils -y  2> /dev/null || apt-get install dnsutils  -y 
HOST="nf"
DOMAIN="20120714.xyz"
URL=${HOST}.${DOMAIN}
#IP=`ping ${URL} -c 1 |awk 'NR==2 {print $4}' |awk -F ':' '{print $1}'`
#IP=`ping ${URL} -c 1 |awk 'NR==2 {print $5}' |awk -F ':' '{print $1}' |sed -nr "s#\(##gp"|sed -nr "s#\)##gp"`
#如果安装了dig也可以这样
IP=`dig ${URL} @114.114.114.114 | awk -F "[ ]+" '/IN/{print $1}' | awk 'NR==2 {print $5}'`
echo "解锁dns服务器IP地址是 ${IP}"



echo "开始修改DNS服务器地址"
chattr -i /etc/resolv.conf && echo -e "nameserver $IP\nnameserver 8.8.8.8 > /etc/resolv.conf && chattr +i /etc/resolv.conf
echo "修改DNS服务器地址完成，开始畅游Netflix吧^_^"
