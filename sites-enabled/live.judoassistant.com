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
    proxy_pass http://judoassistant-web-frontend:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }

  ssl_certificate /etc/letsencrypt/live/judoassistant.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/judoassistant.com/privkey.pem;
  #include /etc/letsencrypt/options-ssl-nginx.conf;
  #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

