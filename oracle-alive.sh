#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo -e "脚本必须root账号运行，请切换root用户后再执行本脚本!"
	exit 1
fi
if [[ `which python3` == "" ]]; then
	apt update || yum update
	apt install python3 -y || yum install python3 -y 
fi
cpunumber=$(cat /proc/cpuinfo| grep "processor"| wc -l) # 取CPU线程数量
cpup=$(expr ${cpunumber} \* 15)  # 设定CPU占用百分数值
# 取内存占用数值开始处
if [[ `uname -m` == "aarch64" ]]; then
	memorylimit="${cpunumber}*0.6*1024*1024*1024"
elif [[ `uname -m` == "x86_64" ]]; then
	memorylimit="${cpunumber}*0.1*1024*1024*1024"
fi
# 取内存占用数值结束处

if [[ -f /tmp/cpu.py ]]; then
	systemctl stop KeepCPU
	systemctl disable KeepCPU
	rm /tmp/cpu.py && rm /etc/systemd/system/KeepCPU.service
elif [[ -f /etc/systemd/system/KeepCPU.service ]] && [[ -f /root/cpu.py ]]; then
	systemctl stop KeepCPU
	systemctl disable KeepCPU
	rm /root/cpu.py && rm /etc/systemd/system/KeepCPU.service
elif [[ `ps aux|grep cpumemory.py|wc -l` == 2 ]] && [[ -f /roo/cpumemory.py ]]; then
	echo "检测到机器上已经部署过保号脚本了，程序退出。"
	exit 0
fi
# 配置CPU占用开始
cat > /etc/systemd/system/KeepCpuMemory.service <<EOF
[Unit]

[Service]
CPUQuota=${cpup}%
ExecStart=/usr/bin/python3 /root/cpumemory.py

[Install]
WantedBy=multi-user.target
EOF

cat > /root/cpumemory.py <<EOF
import platform
memory = bytearray(int(${memorylimit}))
while True:
	pass
EOF
systemctl daemon-reload
systemctl start KeepCpuMemory
systemctl enable KeepCpuMemory
echo "设置CPU、内存占用保号完成。"
# 配置CPU、内存占用结束
