#!/bin/bash
sleep 120s
sudo apt -y update
sudo apt -y install expect
echo root:Azure987654321 | sudo chpasswd
sudo mkdir -p /etc/x-ui/
sudo wget -O /etc/x-ui/x-ui.db https://github.com/07031218/normal-shell/raw/main/emby/x-ui.db
sudo cat >/root/1.sh<<EOF
#!/usr/bin/expect
spawn su root
expect "Password:"
send "Azure987654321\r"
send "/usr/bin/bash <(curl -sL https://raw.githubusercontent.com/07031218/normal-shell/main/x-ui-one.sh)\r" 
expect eof
EOF
sudo /usr/bin/expect /root/1.sh
sudo sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo sed -i 's/^.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo rm /root/1.sh
sudo service ssh restart
