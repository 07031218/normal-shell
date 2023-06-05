#!/bin/bash
# iptables通过设备MAC地址来禁止对应设备连接互联网(治熊孩子专用)
# 根据自己设备的MAC地址进行替换操作即可
# 如果您使用的是 LuCI Web 界面，则可以使用 System 模块来设置开机运行的脚本。
# 登录到 LuCI 界面。
# 单击“System”选项卡。
# 单击“Startup”选项卡。
# 在“Local Startup”文本框中输入您要运行的命令或脚本。
# Powerby 翔翎
if [[ `iptables -L FORWARD -n|grep 'MAC48:98:ca:05:16:27'` == "" ]]; then
	iptables -I FORWARD -m mac --mac-source A8:82:00:C9:C0:E0 -j DROP # 客厅电视有线
	iptables -I FORWARD -m mac --mac-source B0:E4:D5:9B:0B:4A -j DROP # Google TV
	iptables -I FORWARD -m mac --mac-source 48:98:CA:05:16:27 -j DROP # 客厅电视无线
	echo "`date "+%Y-%m-%d %H:%M:%S"` 查询发现当前防火墙中无针对家里电视对互联网的访问的防火墙规则，所以本次操作是屏蔽家里电视对互联网的访问！" > /root/log.txt
else
	iptables -D FORWARD -m mac --mac-source A8:82:00:C9:C0:E0 -j DROP # 客厅电视有线
	iptables -D FORWARD -m mac --mac-source B0:E4:D5:9B:0B:4A -j DROP # Google TV
	iptables -D FORWARD -m mac --mac-source 48:98:CA:05:16:27 -j DROP # 客厅电视无线
	echo "`date "+%Y-%m-%d %H:%M:%S"` 查询发现当前防火墙中存在针对家里电视对互联网的访问的防火墙规则，所以本次操作是放行家里电视对互联网的访问！" > /root/log.txt
fi
