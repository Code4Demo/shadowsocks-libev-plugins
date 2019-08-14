#!/bin/bash

export PATH=$PATH:/usr/local/bin

PORJECTNAME="shadowsocks-libev"

USAGE="Usage: $0 {build|push|release|test} \n
eg. \n
build : build docker image \n
push : push docker to pravite server \n 
release :  build docker image >>> push docker to pravite server \n
"

CURRENTPATH=$(dirname "$0")
PROJECTPATH=$(cd "$CURRENTPATH"; cd ./ ; pwd)
SHELLNAME=$(echo "$0" | awk -F "/" '{print $NF}' | awk -F "." '{print $1}')

#support in -s 
if [ -L "$0" ] ; then 
SHELLPATH=$(echo $(ls -l "$CURRENTPATH"  | grep "$SHELLNAME") | awk  -F "->" '{print $NF}') 
#SHELLNAME=$(echo $SHELLPATH | awk -F "/" '{print $NF}')
PROJECTPATH=$(cd "$(echo ${SHELLPATH%/*})/"; cd ./.. ; pwd)
fi

DOCKERHOST="kineviz" #default use docker.io/kineviz
if [ -z "$2" ]; then
    echo "Default docker registry host : $DOCKERHOST "
else
DOCKERHOST=$2
    echo "Read the docker registry host : $DOCKERHOST "
fi
 
docker_build(){
    cd "${PROJECTPATH}"
    if [ ! -f "${PROJECTPATH}/Dockerfile" ]; then 
    echo "Can't found Dockerfile file"
    exit 1
    else 
        docker build -f ./Dockerfile  -t "${PORJECTNAME}" ./ 
    fi
}

docker_push(){
    echo "will push docker image ${PORJECTNAME} to ${DOCKERHOST}"
    docker tag  "${PORJECTNAME}" "${DOCKERHOST}/${PORJECTNAME}"
    docker push "${DOCKERHOST}/${PORJECTNAME}"
}

run() {

  case "$1" in
    build)
    docker_build
        ;;
    push)
    docker_push
        ;;
    release)
    docker_build
    docker_push
        ;;
    *)
        echo "$USAGE"
     ;;
esac

exit 0;

}

if [ -z "$1" ]; then
    echo "$USAGE"
    exit 0
fi

run "$1"