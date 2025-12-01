#!/usr/bin/env bash
set -e

NEXTCLOUD_DIR="/var/www/nextcloud"
DATA_DIR="${NEXTCLOUD_DATA_DIR:-/share/nextcloud}"

ADMIN_USER=${NEXTCLOUD_ADMIN_USER:-admin}
ADMIN_PASSWORD=${NEXTCLOUD_ADMIN_PASSWORD:-changeme}
TRUSTED_DOMAINS=${NEXTCLOUD_TRUSTED_DOMAINS:-nextcloud.local}

cat >/etc/php83/php-fpm.d/nextcloud.conf <<EOF
[nextcloud]
user = root
group = root
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF

cat >/etc/nginx/nginx.conf <<'EOF'
user  root;
worker_processes  auto;

events { worker_connections 1024; }

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 443 ssl;
        server_name _;

        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

        root /var/www/nextcloud;
        index index.php index.html;

        client_max_body_size 2048M;

        location / {
            rewrite ^ /index.php$request_uri;
        }

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }
}
EOF

if [ ! -f /etc/ssl/certs/nginx-selfsigned.crt ]; then
  mkdir -p /etc/ssl/certs /etc/ssl/private
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/CN=nextcloud"
fi

mkdir -p "$DATA_DIR"

if [ ! -f "${NEXTCLOUD_DIR}/config/config.php" ]; then
  php83 ${NEXTCLOUD_DIR}/occ maintenance:install \
    --database "sqlite" \
    --admin-user "${ADMIN_USER}" \
    --admin-pass "${ADMIN_PASSWORD}" \
    --data-dir "${DATA_DIR}"
fi

php83 ${NEXTCLOUD_DIR}/occ config:system:set trusted_domains 1 --value="${TRUSTED_DOMAINS}"

php-fpm83 -F &
nginx -g "daemon off;"
