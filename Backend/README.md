# FitOverlay Backend

Vapor 4 API for FitOverlay: authentication, licensing, and app-launch configuration.

## Endpoints

### Authentication (`/Authentication`)
- `POST /Authentication/register-code` — send a registration verification code
- `POST /Authentication/register` — register with phone number + code, returns JWT tokens
- `POST /Authentication/login-code` — send a login verification code
- `POST /Authentication/login` — login with phone number + code, returns JWT tokens
- `GET  /Authentication/refresh-token?xxrt=<refresh>` — mint a new access token
- `POST /Authentication/logout` — invalidate the user's tokens (authenticated)

### App Launch (`/App-Launch`)
- `GET /App-Launch/get-client-config` — minimum client version etc.
- `GET /App-Launch/is-user-accepted` — early-access gate (authenticated)

### Licensing (`/License`)
- `POST /License/activate` — activate (or refresh) a device for a licence key
- `POST /License/deactivate` — free an activation slot
- `GET  /License/status?key=...&deviceIdentifier=...` — licence + activation status
- `POST /License/webhooks/stripe` — Stripe purchase webhook (stub, signature verification TODO)
- `POST /License/webhooks/app-store` — App Store server notification webhook (stub, JWS verification TODO)

## Local development

```bash
cp .env.example .env.local
docker compose up -d postgres   # database
docker compose up api-dev       # API with hot reload (nodemon + swift run)
# or natively:
swift run App serve --env local
```

Local DB admin:

- `docker compose up -d pgadmin`
- Open `http://127.0.0.1:5050`, sign in with `admin@example.com` / `admin`

## Environment variables

See `.env.example`. Required: `PRIMARY_POSTGRES_URL`, `REGIONAL_POSTGRES_URL`,
`JWT_ENCRYPTION_SECRET`, `AUTHENTICATION_CODE_DISTANCE`.

## Tests

```bash
swift test --filter '.*UnitTests.*'          # no external dependencies
swift test --filter '.*IntegrationTests.*'   # needs Postgres (env vars above)
```

## Delivery stubs

- Verification codes are **logged, not sent** (`LoggingAuthCodeDeliveryService`) — wire up an
  SMS/email provider for production.
- Purchase webhooks accept a normalized payload without provider signature verification —
  implement Stripe signature / App Store JWS checks before going live.
