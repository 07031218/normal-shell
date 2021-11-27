# **个人常使用的一些脚本集合**

一键回程路由查看脚本（兼容ARM架构）：
```shell
bash <(curl -L -s https://raw.githubusercontent.com/07031218/normal-shell/main/autoBestTrace.sh)
```
WorstTrace一键查看回程路由（BestTrace替代品）
```shell
bash <(curl -L -s https://raw.githubusercontent.com/07031218/normal-shell/main/WorstTrace.sh)
```
京东服务器时间同步脚本【For Linux】：
```shell
bash <(curl -L -s https://raw.githubusercontent.com/07031218/normal-shell/main/timesync.sh)
```
京东服务器时间同步脚本【For Synology】：
```shell
bash <(curl -L -s https://raw.githubusercontent.com/07031218/normal-shell/main/timesync-for-synology.sh)
```
一键测速脚本（兼容ARM架构）：
```shell
bash <(curl -Lso- https://raw.githubusercontent.com/07031218/normal-shell/main/superspeed.sh)
```
一键调优脚本（提升网络链接速度）[Powered by Neko Neko Cloud && Modify by 翔翎]
```shell
bash <(curl -sL https://raw.githubusercontent.com/07031218/normal-shell/net/tools.sh)
```
甲骨文一键DD到Debian 11 脚本（兼容甲骨文AMD和ARM架构,DD完默认密码password，经测试同样适用腾讯云、Do、Azure）
```shell
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/07031218/normal-shell/main/InstallNET.sh') -d 11 -v 64 -p password
```

【调用国内镜像源版】甲骨文一键DD到Debian 11 脚本（兼容甲骨文AMD和ARM架构,DD完默认密码password，经测试同样适用腾讯云、Do、Azure）

```shell
bash <(wget --no-check-certificate -qO- 'https://cdn.jsdelivr.net/gh/07031218/normal-shell@main/InstallNET.sh') -d 11 -v 64 -p password --mirror 'https://mirrors.huaweicloud.com/debian/'
```
x-ui一键安装脚本
```shell
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
```
流媒体解锁一键检测脚本（lmc999版本）
```shell
bash <(curl -L -s https://git.io/JRw8R)
```
流媒体解锁一键检测脚本（sjlleo版本,仅支持检测NF，脚本兼容linux ARM和AMD，以及MacOS 非M1版）
```shell
bash <(curl -sL https://raw.githubusercontent.com/07031218/normal-shell/main/netflix-verify.sh)
```
Argo Tunnel一键部署脚本
```shell
bash <(curl -sL https://raw.githubusercontent.com/07031218/normal-shell/net/onekey-argo-tunnel.sh)
```
plex一键部署脚本 for amd64
```shell
wget https://github.com/07031218/normal-shell/raw/main/plex/plex -O plex && chmod 777 plex && cp plex /usr/bin && plex
```
plex一键部署脚本 for arm64
```shell
wget https://github.com/07031218/normal-shell/raw/main/plex/plex-arm64 -O plex && chmod 777 plex && cp plex /usr/bin && plex
```

