#!/bin/bash
echo -ne "请输入CPU线程数："
read cpunumber
cpup=$(expr ${cpunumber} \* 15)
cat > /etc/systemd/system/KeepCPU.service <<EOF
[Unit]

[Service]
CPUQuota=${cpup}%
ExecStart=/usr/bin/python3 /tmp/cpu.py

[Install]
WantedBy=multi-user.target
EOF

cat > /tmp/cpu.py <<EOF
while True:
  x=1
EOF
systemctl daemon-reload
systemctl enable KeepCPU
systemctl start KeepCPU
echo "设置CPU占用保号完成。"
