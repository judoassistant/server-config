server {
	listen 80;
  listen [::]:80;

  root /var/www/judoassistant.com/html;
  index index.html;

  server_name judoassistant.com www.judoassistant.com;

  location / {
    try_files $uri $uri/ =404;
  }

  location ~ /.well-known/acme-challenge {
    allow all;
    root /var/www/html;
  }
}

