server {
  listen 80;
  listen [::]:80;
  server_name live.judoassistant.com;

  return 301 https://$host$request_uri;
}


server {
  listen 443 ssl;
  add_header Strict-Transport-Security "max-age=63072000; includeSubdomains;";

  server_name live.judoassistant.com;

  location / {
    root   /var/www/live.judoassistant.com/html;
    index  index.html;
    try_files $uri $uri/ /index.html;
  }

  location /ws {
    proxy_pass http://judoassistant-backend:9001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_read_timeout 86400;
  }

  ssl_certificate /etc/letsencrypt/live/judoassistant.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/judoassistant.com/privkey.pem;
  #include /etc/letsencrypt/options-ssl-nginx.conf;
  #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

