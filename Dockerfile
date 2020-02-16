FROM alpine
LABEL maintainer="keytouch"

COPY --from=shadowsocks/shadowsocks-libev /usr/bin/ss-* /usr/bin/

RUN apk add --no-cache \
    ca-certificates \
    rng-tools \
    $(scanelf --needed --nobanner /usr/bin/ss-* \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | sort -u) \
    && apk add --no-cache --virtual .build-deps curl \
    && curl -fsSL https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.0/v2ray-plugin-linux-amd64-v1.3.0.tar.gz \
    | tar -xzoC /usr/local/bin \
    && mv /usr/local/bin/v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin \
    && apk del .build-deps

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8388
ENV PASSWORD=
ENV METHOD      chacha20-ietf-poly1305
ENV TIMEOUT     60
ENV DNS_ADDRS   8.8.8.8,8.8.4.4
ENV ARGS=

EXPOSE 8388/tcp 8388/udp

CMD exec ss-server \
    -s $SERVER_ADDR \
    -p $SERVER_PORT \
    -k ${PASSWORD:-$(hostname)} \
    -m $METHOD \
    -t $TIMEOUT \
    -d $DNS_ADDRS \
    -u \
    $ARGS
