#!/bin/bash
echo=echo
CSI=$($echo -e "\033[")
CEND="${CSI}0m"
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"
CMAGENTA="${CSI}1;35m"
CCYAN="${CSI}1;36m"


OUT_ALERT() {
    echo -e "${CYELLOW}$1${CEND}"
}

OUT_ERROR() {
    echo -e "${CRED}$1${CEND}"

    exit $?
}

OUT_INFO() {
    echo -e "${CCYAN}$1${CEND}"
}
read -p "请输入需要取消解锁的客户端IP地址: " IP && printf "\n"
OUT_INFO "-----------------------------------------------"
OUT_ALERT "[提示] 开始将${IP}从stream配置文件中删除"
#sed -i "34i \        \"${IP}\/32\"," /etc/stream.json
sed -i "/\        \"${IP}\/32\",/d" /etc/stream.json
OUT_INFO "-----------------------------------------------"

OUT_ALERT "[提示] 已将${IP}从stream配置文件中删除，开始重启stream服务"
systemctl restart stream
OUT_INFO "-----------------------------------------------"
OUT_ALERT "[提示] 重启stream服务完成，脚本自动退出"
exit 0
