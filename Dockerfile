FROM shadowsocks/shadowsocks-libev

USER root
LABEL maintainer="Sean Li<lxx8585@gmail.com>"

ENV SIMPLE_OBFS_VER 0.0.5
ENV SIMPLE_OBFS_URL https://github.com/shadowsocks/simple-obfs/archive/v$SIMPLE_OBFS_VER.tar.gz
ENV SIMPLE_OBFS_DIR simple-obfs-$SIMPLE_OBFS_VER

RUN set -ex \
    && apk add --no-cache \
                --virtual .build-deps git \
                                    build-base \
                                    autoconf \
                                    automake \
                                    gettext \
                                    asciidoc \
                                    libtool \
                                    xmlto \
                                    linux-headers \
                                    pcre-dev \
                                    udns-dev \
                                    c-ares-dev \
                                    libev-dev \
                                    libsodium-dev \
                                    mbedtls-dev \
    && git clone https://github.com/shadowsocks/simple-obfs.git /tmp/simple-obfs \
    && cd /tmp/simple-obfs \
        && git submodule update --init --recursive \
    && ./autogen.sh  \
        && ./configure --prefix=/usr \
        && make \
        && make install \
    && apk del .build-deps \
        && rm -rf /tmp/simple-obfs

ENV V2RAY_PLUGIN_VERSION 1.1.0
RUN set -ex \
    && apk add --no-cache \
                --virtual .build-deps tar \
    && wget -cq -O /root/v2ray-plugin.tar.gz https://github.com/shadowsocks/v2ray-plugin/releases/download/v${V2RAY_PLUGIN_VERSION}/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz \
    && tar xvzf /root/v2ray-plugin.tar.gz -C /root \
    && mv /root/v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
    && apk del .build-deps \
        && rm -f /root/v2ray-plugin.tar.gz

USER nobody

CMD exec ss-server \
      -s $SERVER_ADDR \
      -p $SERVER_PORT \
      -k ${PASSWORD:-$(hostname)} \
      -m $METHOD \
      -t $TIMEOUT \
      -d $DNS_ADDRS \
      -u \
      $ARGS