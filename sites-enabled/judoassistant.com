server {
  listen 80;
  listen [::]:80;
  server_name www.judoassistant.com judoassistant.com;

  return 301 https://$host$request_uri;
}


server {
  listen 443 ssl;
  add_header Strict-Transport-Security "max-age=63072000; includeSubdomains;";

  server_name www.judoassistant.com judoassistant.com;

  location / {
    root /var/www/judoassistant.com/html;
    index index.html;
    try_files $uri $uri/ =404;
  }

  ssl_certificate /etc/letsencrypt/live/judoassistant.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/judoassistant.com/privkey.pem;
  #include /etc/letsencrypt/options-ssl-nginx.conf;
  #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

