#!/bin/bash
echo "Updating nginx config"
tee /etc/nginx/sites-available/default << EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files \$uri \$uri/ =404;
        }

        location /api {
                proxy_pass http://127.0.0.1:8080;
        }
}
EOF
cp -r magazynier /var/www/html
service nginx restart
