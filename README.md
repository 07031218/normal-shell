个人常使用的一些脚本集合

一键回程路由查看脚本（兼容ARM架构）：
```
bash <(curl -L -s https://raw.githubusercontent.com/07031218/normal-shell/main/autoBestTrace.sh)
```
WorstTrace一键查看回程路由（BestTrace替代品）
```
bash <(curl -L -s https://raw.githubusercontent.com/07031218/normal-shell/main/WorstTrace.sh)
```
京东服务器时间同步脚本：
```
bash <(curl -L -s https://raw.githubusercontent.com/07031218/normal-shell/main/timesync.sh)
```
一键测速脚本（兼容ARM架构）：
```
bash <(curl -Lso- https://raw.githubusercontent.com/07031218/normal-shell/main/superspeed.sh)
```
一键调优脚本（提升网络链接速度）[Powered by Neko Neko Cloud && Modify by 翔翎]
```
bash <(curl -sL https://raw.githubusercontent.com/07031218/normal-shell/net/tools.sh)
```
甲骨文一键DD到Debian 11 脚本（兼容甲骨文AMD和ARM架构,DD完默认密码password，经测试同样适用腾讯云、Do、Azure）
```
bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/MoeClub/Note/master/InstallNET.sh') -d 11 -v 64 -p password
```
