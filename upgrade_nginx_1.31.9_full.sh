#!/bin/bash
set -e

TARGET_VER="1.31.9"
OPENSSL_VER="3.0.15"
NGINX_BIN="/usr/sbin/nginx"
BUILD_DIR="/tmp/nginx_build_${TARGET_VER}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_CONF="/root/nginx_conf_backup_${TIMESTAMP}"
BACKUP_BIN="${NGINX_BIN}.bak.${TIMESTAMP}"
USE_STATIC_OPENSSL=0

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

echo "=== 2. 检查系统并安装编译依赖 ==="
# 仅在 Debian 11 下处理失效的 bullseye-security 源
if grep -q "bullseye" /etc/os-release 2>/dev/null; then
    sed -i -E '/bullseye-(security|backports)/s/^/#/' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null || true
fi

apt update || true

# 安装基础编译工具、PCRE 和 zlib（兼容 PCRE2 / PCRE3）
apt install -y build-essential curl zlib1g-dev
apt install -y libpcre2-dev || apt install -y libpcre3-dev

# 尝试安装系统 libssl-dev，如果因 EOL 或版本冲突失败，自动切换为静态编译 OpenSSL
if ! apt install -y libssl-dev; then
    echo "警告: 系统 libssl-dev 安装失败，将自动采用静态编译 OpenSSL ${OPENSSL_VER}..."
    USE_STATIC_OPENSSL=1
fi

echo "=== 3. 提取并清理当前 Nginx 编译参数 ==="
RAW_ARGS=$($NGINX_BIN -V 2>&1 | grep "configure arguments:" | sed 's/configure arguments://')
# 剔除 Debian/Ubuntu 打包机残留的第三方模块路径和 =dynamic 动态模块参数
CLEAN_ARGS=$(echo "$RAW_ARGS" | sed -E 's/--add-(dynamic-)?module=[^ ]+//g' | sed -E 's/--with-[^ ]+=dynamic//g')
FINAL_ARGS="$CLEAN_ARGS --with-http_ssl_module --with-http_v2_module --with-stream --with-stream_ssl_module"
echo "清理后的编译参数: $FINAL_ARGS"

echo "=== 4. 下载并编译 Nginx ${TARGET_VER} ==="
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

curl -fSLO "https://nginx.org/download/nginx-${TARGET_VER}.tar.gz"
tar -zxf "nginx-${TARGET_VER}.tar.gz"

if [ "$USE_STATIC_OPENSSL" -eq 1 ]; then
    echo "正在下载 OpenSSL ${OPENSSL_VER} 源码..."
    curl -fSLO "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VER}/openssl-${OPENSSL_VER}.tar.gz"
    tar -zxf "openssl-${OPENSSL_VER}.tar.gz"
    FINAL_ARGS="$FINAL_ARGS --with-openssl=${BUILD_DIR}/openssl-${OPENSSL_VER}"
fi

cd "nginx-${TARGET_VER}"
eval ./configure $FINAL_ARGS
make -j"$(nproc)"

echo "=== 5. 自动修正旧版 SSL 语法与不兼容模块加载 ==="
# 5.1 注释掉旧版动态模块加载，防止 .so 版本不兼容导致启动失败
if [ -f "/etc/nginx/nginx.conf" ]; then
    sed -i 's/^\(\s*\)include \/etc\/nginx\/modules-enabled\/\*\.conf;/\1# include \/etc\/nginx\/modules-enabled\/*.conf;/g' /etc/nginx/nginx.conf
fi

# 5.2 同时扫描 conf.d 和 sites-enabled（兼容 Ubuntu 20.04 与 Debian 11）
for DIR in /etc/nginx/conf.d /etc/nginx/sites-enabled; do
    [ -d "$DIR" ] || continue
    for conf in "$DIR"/*; do
        [ -f "$conf" ] || continue
        # 注释掉已废弃的 ssl on;
        sed -i 's/^\(\s*\)ssl on;/\1# ssl on;/g' "$conf"
        # 给未带 ssl 的 443 端口监听行自动补上 ssl
        sed -i -E '/^\s*#/! { /listen\s+([^;]*:)?443\b/ { /\bssl\b/! s/(listen\s+([^;]*:)?443)\b/\1 ssl/ } }' "$conf"
    done
done
echo "已完成配置文件 SSL 语法检查与修正。"

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
dpkg -l 'nginx*' 2>/dev/null | awk '/^ii/{print $2}' | xargs -r apt-mark hold
rm -rf "$BUILD_DIR"

echo "=== 升级完成 ==="
"$NGINX_BIN" -v
systemctl is-active nginx
