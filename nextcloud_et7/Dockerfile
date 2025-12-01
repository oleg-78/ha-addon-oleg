ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19
FROM $BUILD_FROM

# Install packages
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
    php83-fileinfo \
    php83-iconv \
    php83-sqlite3 \
    php83-ctype \
    openssl \
    curl \
    bash

# Nextcloud vars
ENV NEXTCLOUD_DIR=/var/www/nextcloud
ENV NEXTCLOUD_VERSION=30.0.2

# Download Nextcloud
RUN mkdir -p ${NEXTCLOUD_DIR} && \
    curl -fsSL https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2 -o /tmp/nextcloud.tar.bz2 && \
    tar -xjf /tmp/nextcloud.tar.bz2 -C /var/www && \
    rm /tmp/nextcloud.tar.bz2

# Data dir
RUN mkdir -p /share/nextcloud

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# -------------------------------
# Create s6 service for Nextcloud
# -------------------------------
RUN mkdir -p /etc/services.d/nextcloud

# RUN script for service
RUN bash -c 'cat << EOF > /etc/services.d/nextcloud/run
#!/usr/bin/with-contenv bash
exec /run.sh
EOF'

RUN chmod +x /etc/services.d/nextcloud/run

# No CMD needed: s6-overlay handles startup
