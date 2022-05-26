# **个人常使用的一些脚本集合**

一键回程路由查看脚本（兼容ARM架构）：
```shell
bash <(curl -L -s https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/autoBestTrace.sh)
```
WorstTrace一键查看回程路由（BestTrace替代品）
```shell
bash <(curl -L -s https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/WorstTrace.sh)
```
京东服务器时间同步脚本【For Linux】：
```shell
bash <(curl -L -s https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/timesync.sh)
```
京东服务器时间同步脚本【For Synology】：
```shell
bash <(curl -L -s https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/timesync-for-synology.sh)
```
一键测速脚本（兼容ARM架构）：
```shell
bash <(curl -Lso- https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/superspeed.sh)
```
一键调优脚本（提升网络链接速度）[Powered by Neko Neko Cloud && Modify by 翔翎]
```shell
bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/net/tools.sh)
```
甲骨文一键DD到Debian 11 脚本（兼容甲骨文AMD和ARM架构,DD完默认密码password，经测试同样适用腾讯云、Do、Azure）
```shell
bash <(wget --no-check-certificate -qO- 'https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/InstallNET.sh') -d 11 -v 64 -p password
```

【调用国内镜像源版】甲骨文一键DD到Debian 11 脚本（兼容甲骨文AMD和ARM架构,DD完默认密码password，经测试同样适用腾讯云、Do、Azure）

```shell
bash <(wget --no-check-certificate -qO- 'https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/InstallNET.sh') -d 11 -v 64 -p password --mirror 'https://mirrors.aliyun.com/debian/'
```
x-ui一键安装脚本
```shell
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
```
流媒体解锁一键检测脚本（lmc999版本）
```shell
bash <(curl -L -s check.unlock.media)
```
流媒体解锁一键检测脚本（sjlleo版本,仅支持检测NF，脚本兼容linux ARM和AMD，以及MacOS 非M1版）
```shell
bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/netflix-verify.sh)
```
Argo Tunnel一键部署脚本
```shell
bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/net/onekey-argo-tunnel.sh)
```
一键安装nginx并部署签发SSL
```shell
bash <(curl -s https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/one-key-for-let-s-Encrypt/main/run.sh) 
```
一键Tailscale穿透部署
```shell
bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/onekey-tailscale.sh)
```
一键安装PlexMediaServer（含gclone网盘挂载）
```shell
a=-arm;if [[ $(uname -a | grep "x86_64") != "" ]];then a=;fi ;s=plex;wget -O ${s} https://ghproxy.20120714.xyz/https://github.com/07031218/normal-shell/raw/main/${s}/${s}${a} && chmod +x ${s} && ./${s}
```
Linux系统一键创建、删除删除用户
```shell
bash <(curl -sL https://ghproxy.20120714.xyz/https://raw.githubusercontent.com/07031218/normal-shell/main/user.sh)
```
