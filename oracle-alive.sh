#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo -e "脚本必须root账号运行，请切换root用户后再执行本脚本!"
	exit 1
fi

if [[ `which python3` == "" ]]; then
	apt update || yum update
	apt install python3 -y || yum install python3 -y 
fi
if [[ -f /tmp/cpu.py ]]; then
	systemctl stop KeepCPU
	systemctl disable KeepCPU
	rm /tmp/cpu.py
elif [[ -f /etc/systemd/system/KeepCPU.service ]] && [[ `ps aux|grep cpu.py|wc -l` != 2 ]]; then
	systemctl stop KeepCPU
	systemctl disable KeepCPU
elif [[ `ps aux|grep cpu.py|wc -l` == 2 ]]; then
	echo "检测到机器上已经部署过保号脚本了，程序退出。"
	exit 0
fi
cpunumber=$(cat /proc/cpuinfo| grep "processor"| wc -l)
cpup=$(expr ${cpunumber} \* 15)
cat > /etc/systemd/system/KeepCPU.service <<EOF
[Unit]

[Service]
CPUQuota=${cpup}%
ExecStart=/usr/bin/python3 /root/cpu.py

[Install]
WantedBy=multi-user.target
EOF

cat > /root/cpu.py <<EOF
while True:
  x=1
EOF
systemctl daemon-reload
systemctl enable KeepCPU
systemctl start KeepCPU
echo "设置CPU占用保号完成。"
