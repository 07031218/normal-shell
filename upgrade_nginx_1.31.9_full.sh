#!/bin/bash
set -e

TARGET_VER="1.31.9"
NGINX_BIN="/usr/sbin/nginx"
CONF_DIR="/etc/nginx/conf.d"
BUILD_DIR="/tmp/nginx_build_${TARGET_VER}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_CONF="/root/nginx_conf_backup_${TIMESTAMP}"
BACKUP_BIN="${NGINX_BIN}.bak.${TIMESTAMP}"

if [ "$(id -u)" -ne 0 ]; then
    echo "错误: 请使用 root 用户运行此脚本。"
    exit 1
fi

if [ ! -x "$NGINX_BIN" ]; then
    echo "错误: 未找到 $NGINX_BIN。"
    exit 1
fi

echo "=== 1. 备份现有配置与二进制文件 ==="
if [ -d "/etc/nginx" ]; then
    cp -a /etc/nginx "$BACKUP_CONF"
    echo "配置已备份至: $BACKUP_CONF"
fi
cp -a "$NGINX_BIN" "$BACKUP_BIN"
echo "旧程序已备份至: $BACKUP_BIN"

echo "=== 2. 处理失效源并安装编译依赖 ==="
sed -i '/bullseye-security/s/^/#/' /etc/apt/sources.list 2>/dev/null || true
apt update || true
apt install -y build-essential curl libpcre2-dev libpcre3-dev zlib1g-dev libssl-dev || \
apt install -y build-essential curl libpcre3-dev zlib1g-dev libssl-dev

echo "=== 3. 提取并清理当前 Nginx 编译参数 ==="
RAW_ARGS=$($NGINX_BIN -V 2>&1 | grep "configure arguments:" | sed 's/configure arguments://')
# 剔除 Debian 打包机上的第三方模块路径以及 =dynamic 动态模块，避免缺少依赖或 .so 不兼容
CLEAN_ARGS=$(echo "$RAW_ARGS" | sed -E 's/--add-(dynamic-)?module=[^ ]+//g' | sed -E 's/--with-[^ ]+=dynamic//g')
# 补上常用的静态模块（如 stream 四层转发、SSL、HTTP/2）
FINAL_ARGS="$CLEAN_ARGS --with-http_ssl_module --with-http_v2_module --with-stream --with-stream_ssl_module"
echo "清理后的编译参数: $FINAL_ARGS"

echo "=== 4. 下载并编译 Nginx ${TARGET_VER} ==="
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
curl -fSLO "https://nginx.org/download/nginx-${TARGET_VER}.tar.gz"
tar -zxf "nginx-${TARGET_VER}.tar.gz"
cd "nginx-${TARGET_VER}"

eval ./configure $FINAL_ARGS
make -j"$(nproc)"

echo "=== 5. 自动修正旧版 SSL 语法与不兼容模块加载 ==="
# 5.1 注释掉 /etc/nginx/nginx.conf 中旧版动态模块的加载，防止版本不兼容报错
if [ -f "/etc/nginx/nginx.conf" ]; then
    sed -i 's/^\(\s*\)include \/etc\/nginx\/modules-enabled\/\*\.conf;/\1# include \/etc\/nginx\/modules-enabled\/*.conf;/g' /etc/nginx/nginx.conf
fi

# 5.2 修正 conf.d 下的 ssl on; 和 listen 443;
if [ -d "$CONF_DIR" ]; then
    for conf in "$CONF_DIR"/*.conf; do
        [ -e "$conf" ] || continue
        sed -i 's/^\(\s*\)ssl on;/\1# ssl on;/g' "$conf"
        sed -i -E '/^\s*#/! { /listen\s+([^;]*:)?443\b/ { /\bssl\b/! s/(listen\s+([^;]*:)?443)\b/\1 ssl/ } }' "$conf"
    done
fi

echo "=== 6. 替换二进制文件并校验配置 ==="
systemctl stop nginx || true
cp objs/nginx "$NGINX_BIN"
chmod +x "$NGINX_BIN"

if ! "$NGINX_BIN" -t; then
    echo "错误: nginx -t 校验失败，正在自动回滚程序和配置..."
    cp -a "$BACKUP_BIN" "$NGINX_BIN"
    rm -rf /etc/nginx && cp -a "$BACKUP_CONF" /etc/nginx
    systemctl start nginx || true
    exit 1
fi

systemctl start nginx

echo "=== 7. 锁定 APT 版本并清理临时文件 ==="
apt-mark hold nginx
rm -rf "$BUILD_DIR"

echo "=== 升级完成 ==="
"$NGINX_BIN" -v
systemctl is-active nginx
