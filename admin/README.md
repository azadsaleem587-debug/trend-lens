# TrendLens Admin

Next.js 14 (App Router) + Tailwind admin panel for the TrendLens Node.js
backend. It manages the backend's JSON stores through its `/api/admin/*`
endpoints (all require the `x-admin-key` header).

## Setup

```bash
npm install
cp .env.example .env
# edit .env: ADMIN_API_URL + NEXT_PUBLIC_ADMIN_API_URL point at the backend,
# NEXT_PUBLIC_ADMIN_KEY must equal the backend's ADMIN_KEY
npm run dev
```

Open http://localhost:3001 (or the port Next assigns) and sign in with the
admin key.

## Scripts

- `npm run dev` — development server
- `npm run build` — production build
- `npm start` — serve the production build

## Env vars

| Var | Purpose |
| --- | ------- |
| `ADMIN_API_URL` | Backend base URL, e.g. `http://localhost:3000` (server-side use) |
| `NEXT_PUBLIC_ADMIN_API_URL` | Same value, exposed to the browser (required — fetches run client-side) |
| `NEXT_PUBLIC_ADMIN_KEY` | Must equal the backend's `ADMIN_KEY`; compared at login and sent as `x-admin-key` |

## Pages

- `/` Dashboard — template/upload/storage/AI-cache stats with refresh
- `/templates` — CRUD table + create/edit modal (weekly-drop `isNewDrop` toggle, `aiPrompt` textarea)
- `/users` — premium toggle switch and quota (MB) editor, both PATCH immediately
- `/settings` — backend URL, `/api/health` status, note about the server's `DEPLOY.md`
- `/login` — admin-key gate

## API contract (backend)

The panel expects these backend endpoints:

- `GET /api/admin/stats` → `{ templates, uploads, storageBytes, aiCacheEntries, aiCacheBytes }`
- `GET /api/admin/templates` → array of templates; `POST /api/admin/templates`,
  `PUT /api/admin/templates/:id`, `DELETE /api/admin/templates/:id`
- `GET /api/admin/users` → array of users; `PATCH /api/admin/users/:id`
  with `{ isPremium? , quotaMB? }`
- `GET /api/health` → health JSON (no admin key)

Non-2xx responses should carry `{ "error": "message" }` — the panel surfaces
that message in the UI.

## TODO: real auth

The login gate is a **placeholder**: it compares the entered password against
`NEXT_PUBLIC_ADMIN_KEY` in the browser and stores the key in localStorage.
Anyone who learns the key walks past the gate. For production, POST the
credential to the server and issue an HttpOnly session cookie (or JWT)
verified server-side — e.g. in `middleware.ts` — instead of exposing the key
to the client bundle.
