# Deploying TrendLens Server on Servarica VPS

## 1. Install Node.js (v22+; v24 recommended)

```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version   # expect v24.x
```

## 2. Get the code on the VPS

```bash
sudo mkdir -p /var/www/trend-lens
sudo chown -R $USER:$USER /var/www/trend-lens
cd /var/www/trend-lens
# copy the server/ directory here (scp, rsync, or git clone)
```

## 3. Configure

```bash
cd /var/www/trend-lens/server
cp .env.example .env
nano .env
```

Set at minimum:

- `ADMIN_KEY` — a long random secret (e.g. `openssl rand -hex 32`)
- `UPLOAD_DIR=/var/www/trend-lens/uploads` — persistent path outside the code
  directory, so redeploys never wipe user uploads

```bash
mkdir -p /var/www/trend-lens/uploads
```

## 4. Install dependencies and start with pm2

```bash
npm install --omit=dev
sudo npm install -g pm2
pm2 start src/index.js --name trend-lens
pm2 save
pm2 startup   # follow the printed instructions so pm2 survives reboots
```

## 5. nginx reverse proxy

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    client_max_body_size 110m;   # must exceed MAX_UPLOAD_MB (default 100)

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Reload nginx: `sudo nginx -t && sudo systemctl reload nginx`.

## 6. HTTPS (certbot)

```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.yourdomain.com
```

Certbot renews automatically via its systemd timer.

## 7. Update / redeploy later

```bash
cd /var/www/trend-lens/server
# pull or copy the new code (never commit secrets: .env stays in place)
npm install --omit=dev
pm2 restart trend-lens
```

`data/templates.json` and `data/users.json` live in `server/data/` — back them
up before replacing code (`cp -r data data.bak`), since they are the database.
