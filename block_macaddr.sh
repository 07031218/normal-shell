#!/bin/bash
# iptables通过设备MAC地址来禁止对应设备连接互联网(治熊孩子专用)
# 根据自己设备的MAC地址进行替换操作即可
# 如果您使用的是OpenWRT软路由，在LuCI Web界面，通过 系统 - 启动项 - 本地启动脚本 模块来设置开机执行。
# Powerby 翔翎
if [[ `iptables -L FORWARD -n|grep 'MAC48:98:ca:05:16:27'` == "" ]]; then
	iptables -I FORWARD -m mac --mac-source A8:82:00:C9:C0:E0 -j DROP # 客厅电视有线
	iptables -I FORWARD -m mac --mac-source B0:E4:D5:9B:0B:4A -j DROP # Google TV
	iptables -I FORWARD -m mac --mac-source 48:98:CA:05:16:27 -j DROP # 客厅电视无线
	iptables -I INPUT -m mac --mac-source A8:82:00:C9:C0:E0 -j DROP # 客厅电视有线
	iptables -I INPUT -m mac --mac-source B0:E4:D5:9B:0B:4A -j DROP # Google TV
	iptables -I INPUT -m mac --mac-source 48:98:CA:05:16:27 -j DROP # 客厅电视无线
	echo "`date "+%Y-%m-%d %H:%M:%S"` 查询发现当前防火墙中无针对家里电视对互联网的访问的防火墙规则，所以本次操作是屏蔽家里电视对互联网的访问！" > /root/log.txt
else
	iptables -D FORWARD -m mac --mac-source A8:82:00:C9:C0:E0 -j DROP # 客厅电视有线
	iptables -D FORWARD -m mac --mac-source B0:E4:D5:9B:0B:4A -j DROP # Google TV
	iptables -D FORWARD -m mac --mac-source 48:98:CA:05:16:27 -j DROP # 客厅电视无线
	iptables -D INPUT -m mac --mac-source A8:82:00:C9:C0:E0 -j DROP # 客厅电视有线
	iptables -D INPUT -m mac --mac-source B0:E4:D5:9B:0B:4A -j DROP # Google TV
	iptables -D INPUT -m mac --mac-source 48:98:CA:05:16:27 -j DROP # 客厅电视无线
	echo "`date "+%Y-%m-%d %H:%M:%S"` 查询发现当前防火墙中存在针对家里电视对互联网的访问的防火墙规则，所以本次操作是放行家里电视对互联网的访问！" > /root/log.txt
fi
