1. Create `./infra/docker-secrets/` directory with the following files and secrets:
    1. "GITHUB_SSH_AUTHENTICATION_TOKEN": A Github fine-grained token that allows cloning AutomaUtilities repository (private)

TODOS:
- [ ] CURRENT BRANCH: deploy temporal and temporal worker on fly.io. Delete vapor-queues worker fly.io config and apps in organizations
- [ ] Fix profile picture image generation not working (current problem: OpenAI platform billing hard limit reached)
- [ ] FUTURE: Fix swift protobuf package warnings (find upstream package, make a pull request to swift protobuf to support latest 
    swift version - fix warnings) and update upstream package `Package.swift` to use 
    latest protobuf version.

Local DB admin:
- `docker compose --env-file .env.local up -d pgadmin`
- Open `http://127.0.0.1:5050`
- Sign in with `admin@example.com` / `admin`
- The Postgres server is preconfigured from `PRIMARY_POSTGRES_URL` in `.env.local`

Hoppscotch:
- `docker compose --env-file .env.local up -d hoppscotch`
- Open `http://127.0.0.1:3123`
