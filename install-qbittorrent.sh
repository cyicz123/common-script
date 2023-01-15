#!/bin/bash
INSTALL_PATH="$HOME"

if ! type wget >/dev/null 2>&1; then
    echo "wget doesn't exist!" 1>&2
    exit 1
fi
wget -qO- https://raw.githubusercontent.com/cyicz123/common-script/main/install-docker.sh | bash
# Enable bbr
wget -qO- https://raw.githubusercontent.com/cyicz123/common-script/main/bbr.sh | bash

if [[ $(docker network inspect bridge | grep "EnableIPv6") =~ 'false' ]]
then
    echo 'ipv6 start failed. Exit.' 1>&2
    exit 1
fi

cd "$INSTALL_PATH" || exit
echo "Entry $INSTALL_PATH"
mkdir qb && cd qb || exit
cat > docker-compose.yml << EOF
version: "2"
services:
  qbittorrent: 
    image: linuxserver/qbittorrent:4.4.5
    container_name: qbittorrent
    environment:
      - PUID=0
      - PGID=0
      - TZ=Asia/Shanghai # 你的时区
      - WEBUI_PORT=8081 # 将此处修改成你欲使用的 WEB 管理平台端口 
    volumes:
      - ./config:/config # 绝对路径请修改为自己的config文件夹
      - ./downloads:/downloads # 绝对路径请修改为自己的downloads文件夹
    ports:
      # 要使用的映射下载端口与内部下载端口，可保持默认，安装完成后在管理页面仍然可以改成其他端口。
      - 36881:36881 
      - 36881:36881/udp
      # 此处WEB UI 目标端口与内部端口务必保证相同，见问题1
      - 8081:8081
    restart: unless-stopped
    network_mode: bridge       # 网络模式选择刚才配置的桥接 bridge
EOF
docker-compose up -d