#!/bin/bash

echo ""

# 检查是否已经开启SSH root登录
if sudo grep -q "^PermitRootLogin yes$" /etc/ssh/sshd_config; then
  echo "SSH root登录已开启"
else
  echo "SSH root登录未开启"
fi

# 提示用户是否要开启SSH root登录
read -p "是否要开启SSH root登录？(y/n)" choice
if [ ${choice} == y ] || [ ${choice} == Y ]; then
  if grep -qi "centos" /etc/*release; then
    # 如果当前操作系统是CentOS，则使用以下命令来开启SSH root登录：
    sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo systemctl restart sshd.service
  elif grep -qi "ubuntu" /etc/*release; then
    # 如果当前操作系统是Ubuntu，则使用以下命令来开启SSH root登录：
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo systemctl restart ssh
  elif grep -qi "debian" /etc/*release; then
    # 如果当前操作系统是Debian，则使用以下命令来开启SSH root登录：
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sudo systemctl restart ssh
  else
    # 如果当前操作系统不是CentOS、Ubuntu或Debian，则输出错误信息：
    echo "Unsupported Linux distribution"
  fi

  # 启用密码身份验证
  sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
  sudo systemctl restart sshd.service

  # 要求设置root密码
  echo "请设置root用户的密码："
  sudo passwd root
  sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
  sudo sed -i 's/PubkeyAuthentication yes/PubkeyAuthentication no/g' /etc/ssh/sshd_config
  sudo systemctl restart sshd.service

else
  echo "已取消开启SSH root登录。"
fi
