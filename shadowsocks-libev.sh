#!/bin/bash

CURRENTPATH=$(dirname "$0")
PROJECTPATH=$(cd "$CURRENTPATH"; cd ./.. ; pwd)
PROJECTNAME="shadowsocks-libev"

docker stop ${PROJECTNAME}
docker rm ${PROJECTNAME}

mkdir -p ${PROJECTPATH}/shadowsocks-libev/${PROJECTNAME}
chmod -R 777 ${PROJECTPATH}/shadowsocks-libev/${PROJECTNAME}

docker run -d -it --name ${PROJECTNAME} --restart always  \
-v ${PROJECTPATH}/shadowsocks-libev/${PROJECTNAME}:/.shadowsocks:rw \
-v ${PROJECTPATH}/shadowsocks-libev/:/shadowsocks-libev:rw \
-p 8000-8001:8000-8001 \
shadowsocks-libev \
/usr/bin/ss-manager -c /shadowsocks-libev/shadowsocks-libev.json start

docker logs ${PROJECTNAME}