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
    && curl -L https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.0/v2ray-plugin-linux-amd64-v1.3.0.tar.gz \
    | tar -xzC /usr/local/bin \
    && apk del .build-deps
