#!/usr/bin/env bash
#
# 这是一个用于配置和启动WireGuard VPN服务器的Shell脚本。经由 yuan1am 添加中文注释并略作修改。
#
# 版权所有 (C) 2019 - 2020 Teddysun <i@teddysun.com>
#
# 参考网址:
# https://www.wireguard.com
# https://git.zx2c4.com/WireGuard
# https://teddysun.com/554.html


########################################
############### 输出和日志 ###############
########################################
# 定义红色输出函数
_red() {
    printf '\033[1;31;31m%b\033[0m' "$1"
}

# 定义绿色输出函数
_green() {
    printf '\033[1;31;32m%b\033[0m' "$1"
}

# 定义黄色输出函数
_yellow() {
    printf '\033[1;31;33m%b\033[0m' "$1"
}

# 定义默认输出函数
_echo() {
    printf '\033[1;31;33m%b\033[0m' "$1"
    printf "\n"
}

# 打印带有日期的参数
_printargs() {
    printf -- "%s" "[$(date)] "
    printf -- "%s" "$1"
    printf "\n"
}

# 信息输出函数
_info() {
    _printargs "$@"
}

# 警告输出函数
_warn() {
    printf -- "%s" "[$(date)] "
    _yellow "$1"
    printf "\n"
}

# 错误输出函数，并退出程序
_error() {
    printf -- "%s" "[$(date)] "
    _red "$1"
    printf "\n"
    exit 2
}

# 退出函数，输出终止信息
_exit() {
    printf "\n"
    _red "脚本已被终止。"
    printf "\n"
    exit 1
}


# 设置信号捕获，当脚本接收到INT、QUIT、TERM信号时执行_exit函数
trap _exit INT QUIT TERM

# 获取当前脚本所在目录并赋值给cur_dir变量
cur_dir="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"

# 如果当前用户不是root，则输出错误信息并退出脚本
[ ${EUID} -ne 0 ] && _red "此脚本必须以root身份运行\n" && exit 1


########################################
############### 安装和检查 ###############
########################################
# 检查命令是否存在
_exists() {
    local cmd="$1"
    if eval type type > /dev/null 2>&1; then
        eval type "$cmd" > /dev/null 2>&1
    elif command > /dev/null 2>&1; then
        command -v "$cmd" > /dev/null 2>&1
    else
        which "$cmd" > /dev/null 2>&1
    fi
    local rt=$?
    return ${rt}
}

# 检查 WireGuard 是否已安装
_is_installed() {
    install_flag=(0 0)
    if _exists "wg" && _exists "wg-quick"; then
        install_flag[0]=1
    fi
    if [ -s "/lib/modules/$(uname -r)/extra/wireguard.ko" ] \
    || [ -s "/lib/modules/$(uname -r)/extra/wireguard.ko.xz" ] \
    || [ -s "/lib/modules/$(uname -r)/updates/dkms/wireguard.ko" ] \
    || [ -s "/lib/modules/$(uname -r)/updates/dkms/wireguard.ko.xz" ] \
    || [ -s "/lib/modules/$(uname -r)/kernel/wireguard/wireguard.ko" ] \
    || [ -s "/lib/modules/$(uname -r)/kernel/drivers/net/wireguard/wireguard.ko" ] \
    || [ -s "/lib/modules/$(uname -r)/kernel/drivers/net/wireguard/wireguard.ko.xz" ]; then
        install_flag[1]=1
    fi
    if [ "${install_flag[0]}" = "1" ] && [ "${install_flag[1]}" = "1" ]; then
        return 0
    fi
    if [ "${install_flag[0]}" = "1" ] && [ "${install_flag[1]}" = "0" ]; then
        return 1
    fi
    if [ "${install_flag[0]}" = "0" ] && [ "${install_flag[1]}" = "1" ]; then
        return 2
    fi
    if [ "${install_flag[0]}" = "0" ] && [ "${install_flag[1]}" = "0" ]; then
        return 3
    fi
}

# 获取最新的 WireGuard 模块版本号
get_latest_module_ver() {
    wireguard_ver="$(wget --no-check-certificate -qO- https://api.github.com/repos/WireGuard/wireguard-linux-compat/tags | grep 'name' | head -1 | cut -d\" -f4)"
    if [ -z "${wireguard_ver}" ]; then
        wireguard_ver="$(curl -Lso- https://api.github.com/repos/WireGuard/wireguard-linux-compat/tags | grep 'name' | head -1 | cut -d\" -f4)"
    fi
    if [ -z "${wireguard_ver}" ]; then
        _error "从 github 获取最新的 wireguard 模块版本失败"
    fi
}

# 获取最新的 WireGuard 工具版本号
get_latest_tools_ver() {
    wireguard_tools_ver="$(wget --no-check-certificate -qO- https://api.github.com/repos/WireGuard/wireguard-tools/tags | grep 'name' | head -1 | cut -d\" -f4)"
    if [ -z "${wireguard_tools_ver}" ]; then
        wireguard_tools_ver="$(curl -Lso- https://api.github.com/repos/WireGuard/wireguard-tools/tags | grep 'name' | head -1 | cut -d\" -f4)"
    fi
    if [ -z "${wireguard_tools_ver}" ]; then
        _error "从 github 获取最新的 wireguard 工具版本失败"
    fi
}

# 检查操作系统版本
check_os() {
    _info "正在检查操作系统版本"
    if _exists "virt-what"; then
        virt="$(virt-what)"
    elif _exists "systemd-detect-virt"; then
        virt="$(systemd-detect-virt)"
    fi
    if [ -n "${virt}" -a "${virt}" = "lxc" ]; then
        _error "虚拟化为LXC，不支持。"
    fi
    if [ -n "${virt}" -a "${virt}" = "openvz" ] || [ -d "/proc/vz" ]; then
        _error "虚拟化为OpenVZ，不支持。"
    fi
    [ -z "$(_os)" ] && _error "不支持的操作系统"
    case "$(_os)" in
        ubuntu)
            [ -n "$(_os_ver)" -a "$(_os_ver)" -lt 16 ] && _error "不支持的操作系统，请更换为Ubuntu 16+后再试。"
            ;;
        debian|raspbian)
            [ -n "$(_os_ver)" -a "$(_os_ver)" -lt 8 ] &&  _error "不支持的操作系统，请更换为De(Rasp)bian 8+后再试。"
            ;;
        fedora)
            [ -n "$(_os_ver)" -a "$(_os_ver)" -lt 29 ] && _error "不支持的操作系统，请更换为Fedora 29+后再试。"
            ;;
        centos)
            [ -n "$(_os_ver)" -a "$(_os_ver)" -lt 7 ] &&  _error "不支持的操作系统，请更换为CentOS 7+后再试。"
            ;;
        *)
            _error "不支持的操作系统"
            ;;
    esac
}

# 检查Linux内核版本
check_kernel_version() {
    kernel_version="$(uname -r | cut -d- -f1)"
    if _version_ge ${kernel_version} 5.6.0; then
        return 0
    else
        return 1
    fi
}

# 检测命令执行是否出错
_error_detect() {
    local cmd="$1"
    _info "${cmd}"
    eval ${cmd} 1> /dev/null
    if [ $? -ne 0 ]; then
        _error "执行命令 (${cmd}) 失败，请检查后再试。"
    fi
}

# 比较版本号，判断第一个是否大于第二个
_version_gt(){
    test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"
}

# 比较版本号，判断第一个是否大于等于第二个
_version_ge(){
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"
}


########################################
############### 网络和系统 ###############
########################################
# 获取IPv4地址
_ipv4() {
    local ipv4="$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | \
                   egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\.|^169\.254\." | head -n 1 )"
    [ -z "${ipv4}" ] && ipv4="$( wget -qO- -t1 -T2 ipv4.icanhazip.com )"
    [ -z "${ipv4}" ] && ipv4="$( wget -qO- -t1 -T2 ipinfo.io/ip )"
    printf -- "%s" "${ipv4}"
}

# 获取网络接口卡名称
_nic() {
    local nic=""
    nic="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
    printf -- "%s" "${nic}"
}

# 随机生成端口号
_port() {
    local port="$(shuf -i 1024-20480 -n 1)"
    while true; do
        if _exists "netstat" && netstat -tunlp | grep -w "${port}" > /dev/null 2>&1; then
            port="$(shuf -i 1024-20480 -n 1)"
        else
            break
        fi
    done
    printf -- "%s" "${port}"
}

# 获取操作系统类型
_os() {
    local os=""
    [ -f "/etc/debian_version" ] && source /etc/os-release && os="${ID}" && printf -- "%s" "${os}" && return
    [ -f "/etc/fedora-release" ] && os="fedora" && printf -- "%s" "${os}" && return
    [ -f "/etc/redhat-release" ] && os="centos" && printf -- "%s" "${os}" && return
}

# 获取操作系统的完整名称
_os_full() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

# 获取操作系统的主要版本号
_os_ver() {
    local main_ver="$( echo $(_os_full) | grep -oE  "[0-9.]+")"
    printf -- "%s" "${main_ver%%.*}"
}

# 输出提示信息并等待用户确认
if ! _is_installed; then
    # 如果 WireGuard 没有安装，则输出提示信息并等待用户确认
    _warn "WireGuard依赖于内核，某些VPS机器需自行更换内核后再进行安装，输入回车确认并继续"
    read -p ""
fi

initialize_config() {
    CONFIG_FILE="$cur_dir/wg_default_config.conf"

    if [ ! -f "$CONFIG_FILE" ]; then
        _echo "首次执行脚本，需进行初始化配置。"
        while true; do
            _echo "请根据本机网络环境，选择 Wireguard 运行模式："
            _echo "1. 拥有公网IP（1接口多peers）"
            _echo "2. 处于内网环境（1接口1peer）"
            read -p "输入选择 (1 或 2): " role_choice

            if [ "$role_choice" = "1" ]; then
                read -p "请自定义本机的WireGuard接口名称 [默认: vps]: " default_server_suffix
                DEFAULT_SERVER_SUFFIX=${default_server_suffix:-vps}

                read -p "请输入本机的WireGuard接口地址 [默认: 10.88.88.1]: " server_wg_ipv4
                SERVER_WG_IPV4=${server_wg_ipv4:-10.88.88.1}

                read -p "请输入WireGuard服务端口 [默认: 51820]: " server_wg_port
                SERVER_WG_PORT=${server_wg_port:-51820}

                # read -p "请输入WireGuard接口使用的DNS服务器 [默认: 1.1.1.1]: " client_dns
                # CLIENT_DNS=${client_dns:-1.1.1.1}

                read -p "请自定义对端Peer的接口名称 [默认使用服务器接口名称：home]: " default_client_suffix
                DEFAULT_CLIENT_SUFFIX=${default_client_suffix:-home}

                read -p "请输入对端Peer的起始地址 [默认: 10.88.88.2]: " client_wg_ipv4
                CLIENT_WG_IPV4=${client_wg_ipv4:-10.88.88.2}

                read -p "请输入对端Peer的内网IP地址 [默认: 留空]: " client_lan_ipv4
                CLIENT_LAN_IPV4=${client_lan_ipv4:-}

                cat > "$CONFIG_FILE" << EOF
# 自定义变量
ROLE_CHOICE="$role_choice"
# 本机WireGuard接口名称
DEFAULT_SERVER_SUFFIX="$DEFAULT_SERVER_SUFFIX"
# 本机WireGuard接口的隧道地址
SERVER_WG_IPV4="$SERVER_WG_IPV4"
# WireGuard端口
SERVER_WG_PORT="$SERVER_WG_PORT"
# 对端WireGuard接口名称
DEFAULT_CLIENT_SUFFIX="${DEFAULT_CLIENT_SUFFIX}"
# 对端WireGuard接口地址
CLIENT_WG_IPV4="$CLIENT_WG_IPV4"
# 对端内网IP地址
CLIENT_LAN_IPV4="$CLIENT_LAN_IPV4"
# WireGuard服务器网络接口卡名称
SERVER_WG_NIC="server_$DEFAULT_SERVER_SUFFIX"
EOF
                break
            elif [ "$role_choice" = "2" ]; then
                read -p "请自定义本机的WireGuard接口名称 [默认使用服务器接口名称：home]: " default_client_suffix
                DEFAULT_CLIENT_SUFFIX=${default_client_suffix:-home}

                read -p "请输入本机的WireGuard接口地址 [默认: 10.88.88.2]: " client_wg_ipv4
                CLIENT_WG_IPV4=${client_wg_ipv4:-10.88.88.2}

                read -p "请输入本机的内网IP地址 [默认: 192.168.1.0]: " client_lan_ipv4
                CLIENT_LAN_IPV4=${client_lan_ipv4:-192.168.1.0}

                read -p "请输入对端的公网地址（IP或域名） [默认: abcde.com]: " server_pub_addr
                SERVER_PUB_ADDR=${server_pub_addr:-abcde.com}

                read -p "请输入对端的WireGuard服务端口 [默认: 51820]: " server_wg_port
                SERVER_WG_PORT=${server_wg_port:-51820}

                read -p "请自定义对端的WireGuard接口名称 [默认使用服务器接口名称：ROS]: " default_server_suffix
                DEFAULT_SERVER_SUFFIX=${default_client_suffix:-ROS}

                read -p "请输入对端的WireGuard接口地址 [默认: 10.88.88.1]: " server_wg_ipv4
                SERVER_WG_IPV4=${server_wg_ipv4:-10.88.88.1}

                read -p "请输入对端的WireGuard接口公钥 [默认: 空]: " server_pub_key
                SERVER_PUB_KEY=${server_pub_key:-}

                # read -p "请输入WireGuard接口使用的DNS服务器 [默认: 1.1.1.1]: " client_dns
                # CLIENT_DNS=${client_dns:-1.1.1.1}

                cat > "$CONFIG_FILE" << EOF
# 自定义变量
ROLE_CHOICE="$role_choice"
# 本机WireGuard接口名称
DEFAULT_CLIENT_SUFFIX="$DEFAULT_CLIENT_SUFFIX"
# 本机WireGuard接口的隧道地址
CLIENT_WG_IPV4="$CLIENT_WG_IPV4"
# 本机内网IP地址
CLIENT_LAN_IPV4="$CLIENT_LAN_IPV4"
# 对端公网
SERVER_PUB_ADDR="$SERVER_PUB_ADDR"
# 对端WireGuard端口
SERVER_WG_PORT="$SERVER_WG_PORT"
# 对端WireGuard接口名称
DEFAULT_SERVER_SUFFIX="${DEFAULT_SERVER_SUFFIX}"
# 对端的WireGuard接口地址
SERVER_WG_IPV4="$SERVER_WG_IPV4"
# 对端的WireGuard接口公钥
SERVER_PUB_KEY="$SERVER_PUB_KEY"
# WireGuard服务器网络接口卡名称
SERVER_WG_NIC="client_$DEFAULT_CLIENT_SUFFIX"
EOF
                break
            else
                echo "无效的选择，请重新输入。"
            fi
        done
    fi
}

# 从源码安装wireguard模块
install_wg_module() {
    get_latest_module_ver
    wireguard_name="wireguard-linux-compat-$(echo ${wireguard_ver} | grep -oE '[0-9.]+')"
    wireguard_url="https://github.com/WireGuard/wireguard-linux-compat/archive/${wireguard_ver}.tar.gz"
    cd ${cur_dir}
    _error_detect "wget --no-check-certificate -qO ${wireguard_name}.tar.gz ${wireguard_url}"
    _error_detect "tar zxf ${wireguard_name}.tar.gz"
    _error_detect "cd ${wireguard_name}/src"
    _error_detect "make"
    _error_detect "make install"
    _error_detect "cd ${cur_dir} && rm -fr ${wireguard_name}.tar.gz ${wireguard_name}"
}

# 从源码安装wireguard工具
install_wg_tools() {
    get_latest_tools_ver
    wireguard_tools_name="wireguard-tools-$(echo ${wireguard_tools_ver} | grep -oE '[0-9.]+')"
    wireguard_tools_url="https://github.com/WireGuard/wireguard-tools/archive/${wireguard_tools_ver}.tar.gz"
    cd ${cur_dir}
    _error_detect "wget --no-check-certificate -qO ${wireguard_tools_name}.tar.gz ${wireguard_tools_url}"
    _error_detect "tar zxf ${wireguard_tools_name}.tar.gz"
    _error_detect "cd ${wireguard_tools_name}/src"
    _error_detect "make"
    _error_detect "make install"
    _error_detect "cd ${cur_dir} && rm -fr ${wireguard_tools_name}.tar.gz ${wireguard_tools_name}"
}

# 安装wireguard依赖包
install_wg_pkgs() {
    _info "安装wireguard的依赖包"
    case "$(_os)" in
        ubuntu|debian|raspbian)
            _error_detect "apt-get update"
            _error_detect "apt-get -y install qrencode"
            # _error_detect "apt-get -y install resolvconf"
            _error_detect "apt-get -y install iptables"
            _error_detect "apt-get -y install bc"
            _error_detect "apt-get -y install gcc"
            _error_detect "apt-get -y install make"
            _error_detect "apt-get -y install libmnl-dev"
            _error_detect "apt-get -y install libelf-dev"
            if [ ! -d "/usr/src/linux-headers-$(uname -r)" ]; then
                if [ "$(_os)" = "raspbian" ]; then
                    _error_detect "apt-get -y install raspberrypi-kernel-headers"
                else
                    _error_detect "apt-get -y install linux-headers-$(uname -r)"
                fi
            fi
            ;;
        fedora)
            _error_detect "dnf -y install qrencode"
            # _error_detect "dnf -y install openresolv"
            _error_detect "dnf -y install bc"
            _error_detect "dnf -y install gcc"
            _error_detect "dnf -y install make"
            _error_detect "dnf -y install libmnl-devel"
            _error_detect "dnf -y install elfutils-libelf-devel"
            [ ! -d "/usr/src/kernels/$(uname -r)" ] && _error_detect "dnf -y install kernel-headers" && _error_detect "dnf -y install kernel-devel"
            ;;
        centos)
            _error_detect "yum -y install epel-release"
            _error_detect "yum -y install qrencode"
            _error_detect "yum -y install bc"
            _error_detect "yum -y install gcc"
            _error_detect "yum -y install make"
            _error_detect "yum -y install yum-utils"
            if [ -n "$(_os_ver)" -a "$(_os_ver)" -eq 8 ]; then
                yum-config-manager --enable PowerTools > /dev/null 2>&1 || yum-config-manager --enable powertools > /dev/null 2>&1
            fi
            _error_detect "yum -y install libmnl-devel"
            _error_detect "yum -y install elfutils-libelf-devel"
            [ ! -d "/usr/src/kernels/$(uname -r)" ] && _error_detect "yum -y install kernel-headers" && _error_detect "yum -y install kernel-devel"
            ;;
        *)
            ;; # 什么也不做
    esac
}

# 从软件源安装
install_wg_1() {
    install_wg_pkgs
    _info "从软件源安装WireGuard"
    case "$(_os)" in
        ubuntu)
            _error_detect "apt-get update"
            _error_detect "apt-get -y install wireguard"
            ;;
        debian)
            echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list
            printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
            _error_detect "apt-get update"
            _error_detect "apt-get -y install wireguard"
            ;;
        fedora)
            if [ -n "$(_os_ver)" -a "$(_os_ver)" -lt 31 ]; then
                _error_detect "dnf -y copr enable jdoss/wireguard"
                _error_detect "dnf -y install wireguard-dkms wireguard-tools"
            else
                _error_detect "dnf -y install wireguard-tools"
            fi
            ;;
        centos)
            if [ -n "$(_os_ver)" -a "$(_os_ver)" -eq 7 ]; then
                _error_detect "curl -Lso /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo"
            fi
            if [ -n "$(_os_ver)" -a "$(_os_ver)" -eq 8 ]; then
                _error_detect "curl -Lso /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-8/jdoss-wireguard-epel-8.repo"
            fi
            _error_detect "yum -y install wireguard-dkms"
            _error_detect "yum -y install wireguard-tools"
            ;;
        *)
            ;; # 什么也不做
    esac
}

# 从源码安装
install_wg_2() {
    install_wg_pkgs
    _info "从源码安装WireGuard"
    install_wg_module
    install_wg_tools
}

# 从软件源安装WireGuard工具
install_wg_3() {
    install_wg_pkgs
    _info "从软件源安装WireGuard工具"
    case "$(_os)" in
        ubuntu)
            _error_detect "add-apt-repository ppa:wireguard/wireguard"
            _error_detect "apt-get update"
            _error_detect "apt-get -y install --no-install-recommends wireguard-tools"
            ;;
        debian)
            echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list
            printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable
            _error_detect "apt-get update"
            _error_detect "apt-get -y install --no-install-recommends wireguard-tools"
            ;;
        fedora)
            if [ -n "$(_os_ver)" -a "$(_os_ver)" -lt 31 ]; then
                _error_detect "dnf -y copr enable jdoss/wireguard"
                _error_detect "dnf -y install wireguard-tools"
            else
                _error_detect "dnf -y install wireguard-tools"
            fi
            ;;
        centos)
            if [ -n "$(_os_ver)" -a "$(_os_ver)" -eq 7 ]; then
                _error_detect "curl -Lso /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo"
            fi
            if [ -n "$(_os_ver)" -a "$(_os_ver)" -eq 8 ]; then
                _error_detect "curl -Lso /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-8/jdoss-wireguard-epel-8.repo"
            fi
            _error_detect "yum -y install wireguard-tools"
            ;;
        *)
            ;; # 什么也不做
    esac
}

# 从源码安装WireGuard工具
install_wg_4() {
    install_wg_pkgs
    _info "从源码安装WireGuard工具"
    install_wg_tools
}

# 创建wg接口，本机作为服务端
create_server_if() {
    SERVER_PRIVATE_KEY="$(wg genkey)"
    SERVER_PUBLIC_KEY="$(echo ${SERVER_PRIVATE_KEY} | wg pubkey)"
    CLIENT_PRIVATE_KEY="$(wg genkey)"
    CLIENT_PUBLIC_KEY="$(echo ${CLIENT_PRIVATE_KEY} | wg pubkey)"
    if [ -z "$CLIENT_LAN_IPV4" ]; then
        AllowedIPs=${NEW_CLIENT_WG_IPV4}/32
    else
        AllowedIPs=${NEW_CLIENT_WG_IPV4}/32,${CLIENT_LAN_IPV4}/24
    fi 
    _info "创建本机wireguard接口: /etc/wireguard/server_${DEFAULT_SERVER_SUFFIX}.conf"
    [ ! -d "/etc/wireguard" ] && mkdir -p "/etc/wireguard"
    cat > /etc/wireguard/server_${DEFAULT_SERVER_SUFFIX}.conf <<EOF
# 服务器接口 server_${DEFAULT_SERVER_SUFFIX}
[Interface]
Address = ${SERVER_WG_IPV4}/24
ListenPort = ${SERVER_WG_PORT}
MTU = 1420
PrivateKey = ${SERVER_PRIVATE_KEY}

# 客户端接口 client_${DEFAULT_CLIENT_SUFFIX}
[Peer]
PublicKey = ${CLIENT_PUBLIC_KEY}
AllowedIPs = ${AllowedIPs}
PersistentKeepalive = 25
EOF
    chmod 600 /etc/wireguard/server_${DEFAULT_SERVER_SUFFIX}.conf
}

# 创建对端接口信息供客户端使用，本机作为服务端
create_client_config() {
    _info "创建客户端接口配置: /etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX}"
    cat > /etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX} <<EOF
# 以下信息填在对端客户端上
[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_WG_IPV4}/24
MTU = 1420

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
AllowedIPs = 0.0.0.0/0
Endpoint = ${SERVER_PUB_IPV4}:${SERVER_WG_PORT}
PersistentKeepalive = 25
EOF
    chmod 600 /etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX}
}

# 创建wg接口，本机作为客户端
create_client_if() {
    CLIENT_PRIVATE_KEY="$(wg genkey)"
    CLIENT_PUBLIC_KEY="$(echo ${CLIENT_PRIVATE_KEY} | wg pubkey)"
    _info "创建本机wireguard接口: /etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX}.conf"
    [ ! -d "/etc/wireguard" ] && mkdir -p "/etc/wireguard"
    cat > /etc/wireguard/${DEFAULT_CLIENT_SUFFIX}.conf <<EOF
# 本机接口 client_${DEFAULT_CLIENT_SUFFIX}
[Interface]
Address = ${CLIENT_WG_IPV4}/24
ListenPort = ${SERVER_WG_PORT}
MTU = 1420
PrivateKey = ${CLIENT_PRIVATE_KEY}

# 对端接口 server_${DEFAULT_SERVER_SUFFIX}
[Peer]
PublicKey = ${SERVER_PUB_KEY}
AllowedIPs = 0.0.0.0/0
Endpoint = ${SERVER_PUB_ADDR}:${SERVER_WG_PORT}
PersistentKeepalive = 25
EOF
    chmod 600 /etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX}.conf
    _info "正在创建对端信息: /etc/wireguard/server_${DEFAULT_SERVER_SUFFIX}"
    cat > /etc/wireguard/server_${DEFAULT_SERVER_SUFFIX} <<EOF
对端服务器填入以下信息
PublicKey = ${CLIENT_PUBLIC_KEY=}
AllowedIPs = ${CLIENT_WG_IPV4}/32,${CLIENT_LAN_IPV4}/24
EOF
}

# 生成默认客户端接口的QR码图片
generate_qr() {
    _info "生成默认客户端接口的QR码图片"
    _error_detect "qrencode -s8 -o /etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX}.png < /etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX}"
}

# 启用IP转发
enable_ip_forward() {
    _info "启用IP转发"
    sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf  # 删除现有的IPv4转发设置
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf  # 启用IPv4转发
    sysctl -p >/dev/null 2>&1  # 应用新的系统配置
}

# 设置防火墙规则
set_firewall() {
    source "$cur_dir/wg_default_config.conf" # 确保最新的配置被加载
    _info "设置防火墙规则"
    if _exists "firewall-cmd"; then
        if firewall-cmd --state > /dev/null 2>&1; then
            default_zone="$(firewall-cmd --get-default-zone)"
            if [ "$(firewall-cmd --zone=${default_zone} --query-masquerade)" = "no" ]; then
                _error_detect "firewall-cmd --permanent --zone=${default_zone} --add-masquerade"
            fi
            if ! firewall-cmd --list-ports | grep -qw "${SERVER_WG_PORT}/udp"; then
                _error_detect "firewall-cmd --permanent --zone=${default_zone} --add-port=${SERVER_WG_PORT}/udp"
            fi
            _error_detect "firewall-cmd --reload"
        else
            _warn "Firewalld 服务单元未运行，请启动它并手动设置"
            _warn "也许您需要像下面这样运行这些命令:"
            _warn "systemctl start firewalld"
            _warn "firewall-cmd --permanent --zone=public --add-masquerade"
            _warn "firewall-cmd --permanent --zone=public --add-port=${SERVER_WG_PORT}/udp"
            _warn "firewall-cmd --reload"
        fi
    else
        if _exists "iptables"; then
            iptables -A INPUT -p udp --dport ${SERVER_WG_PORT} -j ACCEPT
            iptables -A FORWARD -i ${SERVER_WG_NIC} -j ACCEPT
            iptables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
            iptables-save > /etc/iptables.rules
            if [ -d "/etc/network/if-up.d" ]; then
                cat > /etc/network/if-up.d/iptables <<EOF
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.rules
EOF
                chmod +x /etc/network/if-up.d/iptables
            fi
        fi
    fi
}

# WireGuard 安装完成
install_completed() {
    source "$cur_dir/wg_default_config.conf" # 确保最新的配置被加载
    _info "通过 wg-quick 启动 WireGuard 服务 ${SERVER_WG_NIC}"
    _error_detect "systemctl daemon-reload"
    _error_detect "systemctl start wg-quick@${SERVER_WG_NIC}"
    _error_detect "systemctl enable wg-quick@${SERVER_WG_NIC}"
    # 根据 ROLE_CHOICE 的值判断是服务端还是客户端
    if [ "$ROLE_CHOICE" = "1" ]; then
        _info "WireGuard 安装完成"
        _info ""
        _info "当前机器为服务端"
        _info ""
        _info "对端配置文件地址如下:"
        _info "$(_green "/etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX}")"
        _info ""
        _info "WireGuard VPN 默认客户端二维码如下:"
        _info "$(_green "/etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX}.png")"
        _info ""
        _info "下载并使用您的设备扫描此二维码"
        _info ""
        _info "尽情享受吧"
    elif [ "$ROLE_CHOICE" = "2" ]; then
        _info "WireGuard 安装完成"
        _info ""
        _info "当前机器为客户端"
        _info ""
        _info "对端信息存放于 /etc/wireguard/server_${DEFAULT_CLIENT_SUFFIX}"
        _info "也可以复制一下内容"
        _info ""
        _info "请在对端接口的对应Peers里填入本机公钥:"
        _info "$(_green "$CLIENT_PUBLIC_KEY")"
        _info ""
        _info "请在对端接口的对应Peers里填入Allowips:"
        _info "$(_green "$CLIENT_WG_IPV4/32,$CLIENT_LAN_IPV4/24")"
        _info ""
        _info "尽情享受吧"
    fi
}

check_version() {
    _is_installed
    rt=$?
    if [ ${rt} -eq 0 ]; then
        _exists "modinfo" && installed_wg_ver="$(modinfo -F version wireguard)"
        [ -n "${installed_wg_ver}" ] && echo "wireguard-dkms 版本 : $(_green ${installed_wg_ver})"
        installed_wg_tools_ver="$(wg --version | awk '{print $2}' | grep -oE '[0-9.]+')"
        [ -n "${installed_wg_tools_ver}" ] && echo "wireguard-tools 版本: $(_green ${installed_wg_tools_ver})"
        return 0
    elif [ ${rt} -eq 1 ]; then
        _red "WireGuard 工具存在，但WireGuard模块不存在\n" && return 1
    elif [ ${rt} -eq 2 ]; then
        _red "WireGuard模块存在，但WireGuard工具不存在\n" && return 2
    elif [ ${rt} -eq 3 ]; then
        _red "WireGuard 未安装\n" && return 3
    fi
}

# 添加客户端
add_peers() {
    source "$cur_dir/wg_default_config.conf" # 确保最新的配置被加载
    if ! _is_installed; then
        _red "WireGuard 未安装，请先安装后重试\n" && exit 1
    fi
    if [ "$ROLE_CHOICE" = "2" ]; then
        _red "当前为1对1模式，请使用安装功能新增 Wireguard 接口\n" && exit 1
    fi

    default_server_if="/etc/wireguard/${SERVER_WG_NIC}.conf"
    default_client_if="/etc/wireguard/client_${DEFAULT_CLIENT_SUFFIX}"
    [ ! -s "${default_server_if}" ] && echo "默认服务器接口不存在 ($(_red ${default_server_if}))" && exit 1
    [ ! -s "${default_client_if}" ] && echo "默认客户端接口不存在，当前不是服务端模式，无法添加客户端" && exit 1
    while true; do
        read -p "请输入新的Peer名称 (例如: wg1):" client
        if [ -z "${client}" ]; then
            _red "Peer名称不能为空\n"
        else
            new_client_if="/etc/wireguard/client_${client}"
            if [ "${client}" = "${DEFAULT_CLIENT_SUFFIX}" ]; then
                echo "默认Peer ($(_yellow ${client})) 已存在，请重新输入"
            elif [ -s "${new_client_if}" ]; then
                echo "Peer ($(_yellow ${client})) 已存在，请重新输入"
            else
                # 一旦用户输入有效的 Peer 名称，立即请求输入内网 IP 地址
                read -p "请输入对端Peer的内网IP地址 [默认: 留空]: " new_client_lan_ipv4
                NEW_CLIENT_LAN_IPV4=${new_client_lan_ipv4:-}
                break
            fi
        fi
    done   
    NEW_CLIENT_PRIVATE_KEY="$(wg genkey)"
    NEW_CLIENT_PUBLIC_KEY="$(echo ${NEW_CLIENT_PRIVATE_KEY} | wg pubkey)"
    SERVER_PUBLIC_KEY="$(grep -w "PublicKey" ${default_client_if} | awk '{print $3}')"
    CLIENT_ENDPOINT="$(grep -w "Endpoint" ${default_client_if} | awk '{print $3}')"
    # 获取客户端 IP 地址
    client_files=($(find /etc/wireguard/ -name "client_*" | sort))
    client_ipv4=()
    for ((i=0; i<${#client_files[@]}; i++)); do
        tmp_ipv4="$(grep -w "Address" ${client_files[$i]} | awk '{print $3}' | cut -d\/ -f1 )"
        client_ipv4=(${client_ipv4[@]} ${tmp_ipv4})
    done
    # Sort array
    client_ipv4_sorted=($(printf '%s\n' "${client_ipv4[@]}" | sort -V))
    index=$(expr ${#client_ipv4[@]} - 1)
    last_ip=$(echo ${client_ipv4_sorted[$index]} | cut -d. -f4)
    issue_ip_last=$(expr ${last_ip} + 1)
    [ ${issue_ip_last} -gt 254 ] && _red "Too many clients, IP addresses might be not enough\n" && exit 1
    ipv4_comm=$(echo ${client_ipv4[$index]} | cut -d. -f1-3)  
    NEW_CLIENT_WG_IPV4="${ipv4_comm}.${issue_ip_last}"
    if [ -z "$NEW_CLIENT_LAN_IPV4" ]; then
        AllowedIPs=${NEW_CLIENT_WG_IPV4}/32
    else
        AllowedIPs=${NEW_CLIENT_WG_IPV4}/32,${NEW_CLIENT_LAN_IPV4}/24
    fi   
    cat > ${new_client_if} <<EOF
# 以下信息填在对端客户端上
[Interface]
PrivateKey = ${NEW_CLIENT_PRIVATE_KEY}
Address = ${NEW_CLIENT_WG_IPV4}/24
MTU = 1420

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
AllowedIPs = 0.0.0.0/0
Endpoint = ${CLIENT_ENDPOINT}
EOF
    cat >> ${default_server_if} <<EOF

# 客户端接口 client_${client}
[Peer]
PublicKey = ${NEW_CLIENT_PUBLIC_KEY}
AllowedIPs = ${AllowedIPs}
PersistentKeepalive = 25
EOF
    chmod 600 ${new_client_if}
    echo "添加 WireGuard 客户端 ($(_green ${client})) 完成"
    systemctl restart wg-quick@${SERVER_WG_NIC}
    # 生成新的二维码图片
    qrencode -s8 -o ${new_client_if}.png < ${new_client_if}
    echo "生成新客户端 ($(_green ${client})) 的二维码图片完成"
    echo
    echo "WireGuard VPN 新客户端 ($(_green ${client})) 文件如下:"
    _green "/etc/wireguard/client_${client}\n"
    echo
    echo "WireGuard VPN 新客户端 ($(_green ${client})) 的二维码如下:"
    _green "/etc/wireguard/client_${client}.png\n"
    echo "下载并使用您的设备扫描此二维码，尽情享受吧"
}

remove_peers() {
    source "$cur_dir/wg_default_config.conf" # 确保最新的配置被加载
    if ! _is_installed; then
        _red "WireGuard 未安装，请先安装后重试\n" && exit 1
    fi
    if [ "$ROLE_CHOICE" = "2" ]; then
        _red "当前为1对1模式，无法删除\n" && exit 1
    fi
    default_server_if="/etc/wireguard/${SERVER_WG_NIC}.conf"
    [ ! -s "${default_server_if}" ] && echo "默认服务器接口不存在 ($(_red ${default_server_if}))" && exit 1
    while true; do
        read -p "请输入要删除的Peer名称 (例如: wg1):" client
        if [ -z "${client}" ]; then
            _red "Peer名称不能为空\n"
        else
            if [ "${client}" = "${DEFAULT_CLIENT_SUFFIX}" ]; then
                echo "默认客户端 ($(_yellow ${client})) 不能被删除"
            else
                break
            fi
        fi
    done
    client_if="/etc/wireguard/client_${client}"
    [ ! -s "${client_if}" ] && echo "客户端文件不存在 ($(_red ${client_if}))" && exit 1
    tmp_tag="$(grep -w "Address" ${client_if} | awk '{print $3}' | cut -d\/ -f1 )"
    sed -i '/'"$client"'/,+6d' ${default_server_if}
    # 删除客户端接口文件
    rm -f ${client_if}
    [ -s "/etc/wireguard/client_${client}.png" ] && rm -f /etc/wireguard/client_${client}.png
    systemctl restart wg-quick@${SERVER_WG_NIC}
    echo "客户端名称 ($(_green ${client})) 已被删除"
}

# 列出客户端
list_peers() {
    # 检查是否安装了WireGuard
    source "$cur_dir/wg_default_config.conf" # 确保最新的配置被加载
    if ! _is_installed; then
        _red "WireGuard 未安装，请先安装后重试\n" && exit 1
    fi
    if [ "$ROLE_CHOICE" = "2" ]; then
        _red "当前为1对1模式，请前往 /etc/wireguard/ 文件夹查看\n" && exit 1
    fi
    default_server_if="/etc/wireguard/server_${DEFAULT_SERVER_SUFFIX}.conf"
    [ ! -s "${default_server_if}" ] && echo "默认服务器接口 ($(_red server_${DEFAULT_SERVER_SUFFIX})) 不存在" && exit 1
    local line="+-------------------------------------------------------------------------+\n"
    local string=%-35s
    printf "${line}|${string} |${string} |\n${line}" " 客户端接口" " 客户端IP"
    client_files=($(find /etc/wireguard/ -name "client_*" ! -name "*.png" | sort))
    ips=($(grep -w "AllowedIPs" ${default_server_if} | awk '{print $3}'))
    [ ${#client_files[@]} -ne ${#ips[@]} ] && echo "/etc/wireguard 中缺少一个或多个客户端接口文件" && exit 1
    for ((i=0; i<${#ips[@]}; i++)); do
        tmp_ipv4="$(echo ${ips[$i]} | cut -d\/ -f1)"
        for ((j=0; j<${#client_files[@]}; j++)); do
            if grep -qw "${tmp_ipv4}" "${client_files[$j]}"; then
                printf "|${string} |${string} |\n" " ${client_files[$j]}" " ${ips[$i]}"
                break
            fi
        done
    done
    printf ${line}
}

# 从软件源安装
install_from_repo() {
    检查是否已安装
    _is_installed
    rt=$?
    if [ ${rt} -eq 0 ]; then
        _red "WireGuard已经安装\n" && exit 0
    fi
    check_os
    if check_kernel_version; then
        if [ ${rt} -eq 2 ]; then
            install_wg_3
        else
            _error "WireGuard模块不存在，请检查您的内核"
        fi
    else
        install_wg_1
    fi
    initialize_config
    source "$CONFIG_FILE" # 确保最新的配置被加载
    if [ "$ROLE_CHOICE" = "1" ]; then
        create_server_if
        create_client_config
        generate_qr
    elif [ "$ROLE_CHOICE" = "2" ]; then
        create_client_if
    else
        _error "无效的 ROLE_CHOICE 值: $ROLE_CHOICE" && exit 1
    fi    
    enable_ip_forward
    set_firewall
    install_completed
}

# 从源码安装
install_from_source() {
    # 检查是否已安装
    _is_installed
    rt=$?
    if [ ${rt} -eq 0 ]; then
        _red "WireGuard已经安装\n" && exit 0
    fi
    check_os
    if check_kernel_version; then
        if [ ${rt} -eq 2 ]; then
            install_wg_4
        else
            _error "WireGuard模块不存在，请检查您的内核"
        fi
    else
        install_wg_2
    fi
    initialize_config
    source "$cur_dir/wg_default_config.conf" # 确保最新的配置被加载
    if [ "$ROLE_CHOICE" = "1" ]; then
        create_server_if
        create_client_config
        generate_qr
    elif [ "$ROLE_CHOICE" = "2" ]; then
        create_client_if
    else
        _error "无效的 ROLE_CHOICE 值: $ROLE_CHOICE" && exit 1
    fi    
    enable_ip_forward
    set_firewall
    install_completed
}

# 从源码升级
update_from_source() {
    if check_version > /dev/null 2>&1; then
        restart_flg=0
        get_latest_module_ver
        wg_ver="$(echo ${wireguard_ver} | grep -oE '[0-9.]+')"
        _info "wireguard-dkms 版本: $(_green ${installed_wg_ver})"
        _info "wireguard-dkms 最新版本: $(_green ${wg_ver})"
        if check_kernel_version; then
            _info "wireguard-dkms 已合并到 Linux >= 5.6，因此不再需要此兼容模块"
        else
            if _version_gt "${wg_ver}" "${installed_wg_ver}"; then
                _info "开始升级 wireguard-dkms"
                install_wg_module
                _info "升级 wireguard-dkms 完成"
                restart_flg=1
            else
                _info "wireguard-dkms 没有可用的更新"
            fi
        fi
        get_latest_tools_ver
        wg_tools_ver="$(echo ${wireguard_tools_ver} | grep -oE '[0-9.]+')"
        _info "wireguard-tools 版本: $(_green ${installed_wg_tools_ver})"
        _info "wireguard-tools 最新版本: $(_green ${wg_tools_ver})"
        if _version_gt "${wg_tools_ver}" "${installed_wg_tools_ver}"; then
            _info "开始升级 wireguard-tools"
            install_wg_tools
            _info "升级 wireguard-tools 完成"
            restart_flg=1
        else
            _info "wireguard-tools 没有可用的更新"
        fi
        if [ ${restart_flg} -eq 1 ]; then
            _error_detect "systemctl daemon-reload"
            _error_detect "systemctl restart wg-quick@${SERVER_WG_NIC}"
        fi
    else
        _red "WireGuard 未安装，也许您需要先安装它\n"
    fi
}

# 卸载WireGuard
uninstall_wg() {
    if ! _is_installed; then
        _error "WireGuard未安装"
    fi
    _info "开始卸载WireGuard"
    # 首先停止wireguard
    _error_detect "systemctl stop wg-quick@${SERVER_WG_NIC}"
    _error_detect "systemctl disable wg-quick@${SERVER_WG_NIC}"
    # 如果wireguard是从软件源安装的
    if _exists "yum" && _exists "rpm"; then
        if rpm -qa | grep -q wireguard-dkms; then
            _error_detect "yum -y remove wireguard-dkms"
        fi
        if rpm -qa | grep -q wireguard-tools; then
            _error_detect "yum -y remove wireguard-tools"
        fi
    elif _exists "apt" && _exists "apt-get"; then
        if apt list --installed | grep -q wireguard-dkms; then
            _error_detect "apt-get -y remove wireguard-dkms"
        fi
        if apt list --installed | grep -q wireguard-tools; then
            _error_detect "apt-get -y remove wireguard-tools"
        fi
    fi
    # 如果wireguard是从源码安装的
    if _is_installed; then
        _error_detect "rm -f /usr/bin/wg"
        _error_detect "rm -f /usr/bin/wg-quick"
        _error_detect "rm -f /usr/share/man/man8/wg.8"
        _error_detect "rm -f /usr/share/man/man8/wg-quick.8"
        _exists "modprobe" && _error_detect "modprobe -r wireguard"
    fi
    [ -d "/etc/wireguard" ] && _error_detect "rm -fr /etc/wireguard"
    _info "WireGuard卸载完成"
}

show_help() {
    printf "
用法  : $0 [选项]
选项:
        -h, --help       打印此帮助文本并退出
        -r, --repo       从仓库安装WireGuard（建议本地环境使用）
        -s, --source     从源码安装WireGuard（建议外网环境使用）
        -u, --update     从源码升级WireGuard（建议外网环境使用）
        -v, --version    如果已安装，打印WireGuard版本
        -a, --add        添加WireGuard Peer
        -d, --del        删除WireGuard Peer
        -l, --list       列出所有WireGuard Peers的IP
        -n, --uninstall  卸载WireGuard

"
}


########################################
################ 流程控制 ################
########################################
main() {
    action="$1"
    [ -z "${action}" ] && show_help && exit 0
    case "${action}" in
        -h|--help)
            show_help
            ;;
        -r|--repo)
            install_from_repo
            ;;
        -s|--source)
            install_from_source
            ;;
        -u|--update)
            update_from_source
            ;;
        -v|--version)
            check_version
            ;;
        -a|--add)
            add_peers
            ;;
        -d|--del)
            remove_peers
            ;;
        -l|--list)
            list_peers
            ;;
        -n|--uninstall)
            uninstall_wg
            ;;
        *)
            show_help
            ;;
    esac
}

# 默认变量
# 服务器公网IPv4地址
SERVER_PUB_IPV4="${VPN_SERVER_PUB_IPV4:-$(_ipv4)}"
# 服务器公网网络接口卡
SERVER_PUB_NIC="${VPN_SERVER_PUB_NIC:-$(_nic)}"
# WireGuard服务器网络接口卡名称
SERVER_WG_NIC="${VPN_SERVER_WG_NIC:-wg0}"


main "$@"
