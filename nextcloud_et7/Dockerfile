ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

RUN apk add --no-cache \
    nginx \
    php83 \
    php83-fpm \
    php83-gd \
    php83-json \
    php83-mbstring \
    php83-opcache \
    php83-xml \
    php83-zip \
    php83-curl \
    php83-dom \
    php83-pdo \
    php83-session \
    php83-simplexml \
    php83-fileinfo \
    php83-ctype \
    php83-openssl \
    php83-iconv \
    php83-xmlreader \
    php83-xmlwriter \
    php83-sqlite3 \
    bash \
    curl \
    openssl

ENV NEXTCLOUD_DIR=/var/www/nextcloud
ENV NEXTCLOUD_VERSION=30.0.2

RUN mkdir -p ${NEXTCLOUD_DIR} && \
    curl -fsSL https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2 -o /tmp/nextcloud.tar.bz2 && \
    tar -xjf /tmp/nextcloud.tar.bz2 -C /var/www && \
    rm /tmp/nextcloud.tar.bz2

RUN mkdir -p /share/nextcloud

COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 443

CMD ["/run.sh"]
