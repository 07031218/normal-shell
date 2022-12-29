#!/bin/bash
cat > /usr/bin/tongzhi <<EOF
#!/bin/bash
baseip=\$(curl -4 ip.sb)
if [[ -d /tmp/xmr ]]||[[ -f /tmp/config.json ]]||[[ -f /usr/.work/work32 ]]||[[ -f /usr/.work/work64 ]]; then
  # 下方对照修改填写自己tgbot的apitoken和自己的TGID即可
	curl -s "https://api.telegram.org/bot{apitoken}/sendMessage?chat_id={tgid}&text=主人，本机发现挖矿程序，我的IP地址为：\${baseip}"
fi
EOF
chmod +x /usr/bin/tongzhi
sed -i 'N;8 a */1 * * * * /usr/bin/tongzhi' /etc/crontab
/etc/init.d/cron restart
echo "挖坑检测程序部署完成···"
