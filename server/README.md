# TrendLens Server

Express backend for the TrendLens trend-template studio. Runs on a $0 stack:
no database — JSON files under `data/` are the only stores.

## Local run

```bash
cd ~/workspace/trend-lens/server
cp .env.example .env   # then set ADMIN_KEY to something real
npm install
npm start              # -> node src/index.js, default port 3000
```

Boot creates `uploads/`, `cache/ai/`, and `data/` if missing.

## Endpoints

| Method | Path                        | Auth              | Description                                              |
|--------|-----------------------------|-------------------|----------------------------------------------------------|
| GET    | `/api/health`               | —                 | `{status:"ok", time}` liveness check                     |
| GET    | `/api/templates`            | —                 | Public template list (from `data/templates.json`)        |
| POST   | `/api/ai/style`             | rate-limited      | Free AI image proxy (Pollinations), disk-cached          |
| POST   | `/api/upload`               | `x-premium: true` | Premium-only file upload (images/videos), multer disk    |
| GET    | `/api/admin/stats`          | `x-admin-key`     | Template/upload/cache counts + byte totals               |
| GET    | `/api/admin/templates`      | `x-admin-key`     | List templates                                           |
| POST   | `/api/admin/templates`      | `x-admin-key`     | Create template `{id, title, ...}`                        |
| PUT    | `/api/admin/templates/:id`   | `x-admin-key`     | Update template (id is immutable)                        |
| DELETE | `/api/admin/templates/:id`  | `x-admin-key`     | Delete template                                          |
| GET    | `/api/admin/users`          | `x-admin-key`     | List users                                               |
| PATCH  | `/api/admin/users/:id`      | `x-admin-key`     | Set `{isPremium?, quotaMb?}`; auto-creates the user      |

Uploaded files are served statically at `/uploads/<userId>/<filename>`.

## POST /api/ai/style

Body: `{prompt: string, width?: number, height?: number, seed?: number}`.

Proxies `https://image.pollinations.ai` (free, no key) and caches results on
disk under `AI_CACHE_DIR`, keyed by `sha256(prompt|width|height|seed)`.
`X-Cache: HIT` on cache hits, `X-Cache: MISS` on fresh generations.
Rate limit: `RATE_LIMIT_PER_HOUR` (default 20) per IP per hour.
Upstream failures return `502 {"error":"ai_upstream_failed"}`.

## POST /api/upload

- Single file in field `file`; only `image/*` and `video/*` mimetypes.
- Size cap from `MAX_UPLOAD_MB` (default 100).
- Requires header `x-premium: true`, else `403 {"error":"cloud_storage_requires_premium"}`.
  (TODO: replace with real JWT auth.)
- `x-user-id` header is sanitized to `[a-zA-Z0-9_-]` (default `"anon"`).
- Returns `{url: "/uploads/<userId>/<filename>", size}`.

## Environment variables

See `.env.example` for the full documented list:
`PORT`, `UPLOAD_DIR`, `AI_CACHE_DIR`, `ADMIN_KEY`, `MAX_UPLOAD_MB`,
`RATE_LIMIT_PER_HOUR` (plus optional `DATA_DIR`).

## Layout

```
server/
  src/index.js                 # Express app, boot-time dir creation
  src/middleware/admin_auth.js # x-admin-key check (401 otherwise)
  src/routes/templates.js      # GET /api/templates
  src/routes/ai.js             # POST /api/ai/style (proxy + disk cache)
  src/routes/upload.js         # POST /api/upload (premium, multer disk)
  src/routes/admin.js          # /api/admin/* (stats, templates CRUD, users)
  src/lib/store.js             # JSON file read/write helpers
  data/                        # templates.json (seeded), users.json (auto)
  uploads/  cache/ai/          # runtime dirs, git-ignored
```
