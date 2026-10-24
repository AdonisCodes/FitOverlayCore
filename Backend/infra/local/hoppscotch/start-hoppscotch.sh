#!/bin/sh
set -eu

cd /dist/backend
./node_modules/.bin/prisma db push

node <<'NODE'
const fs = require('fs');

const path = '/site/selfhost-web/index.html';
const html = fs.readFileSync(path, 'utf8');
const env = {
  VITE_BASE_URL: process.env.VITE_BASE_URL || '',
  VITE_BACKEND_API_URL: process.env.VITE_BACKEND_API_URL || '',
  VITE_ADMIN_URL: process.env.VITE_ADMIN_URL || '',
  VITE_SHORTCODE_BASE_URL:
    process.env.VITE_SHORTCODE_BASE_URL || process.env.VITE_BASE_URL || '',
};

const marker = `JSON.parse('"import_meta_env_placeholder"')`;
const replacement = `JSON.parse('${JSON.stringify(env).replace(/'/g, "\\'")}')`;

if (!html.includes(marker)) {
  throw new Error(`Frontend env placeholder not found in ${path}`);
}

fs.writeFileSync(path, html.replace(marker, replacement));
NODE

caddy run --config /etc/caddy/aio-multiport-setup.Caddyfile --adapter caddyfile &
exec node /dist/backend/dist/src/main.js
