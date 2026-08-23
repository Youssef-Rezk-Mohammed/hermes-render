# Hermes Agent on Back4app Containers (Free, No Credit Card) — powered by OpenCode Zen

Self-hosted Hermes Agent (gateway + web dashboard) on **Back4app Containers** free tier,
with persistent memory via Cloudflare R2 so redeploys don't wipe sessions/skills.
The LLM is **OpenCode Zen** (an OpenAI-compatible gateway) — the only provider key you need.

> Why Back4app: free tier needs **no credit card**, gives **256 MB RAM / 0.25 CPU / 100 GB transfer**,
> and **does not force your container to sleep**. It assigns a `$PORT` env var and routes traffic there.

## What this repo deploys
- The **official Hermes image's own s6 init** (`/init`, the inherited ENTRYPOINT) supervises
  the gateway (`:8642`) and the dashboard (bound to Back4app's `$PORT` on `0.0.0.0`).
- A `cont-init.d` script runs at boot: restores `/opt/data` from R2, writes
  `~/.hermes/config.yaml` with the OpenCode Zen endpoint + dashboard basic auth, and starts
  the R2 sync loop.
- No supervisord, no ENTRYPOINT override — we let the image manage its own lifecycle.

## 1. Cloudflare R2 (one-time, no card)
1. Cloudflare dashboard → **R2 Object Storage** → create bucket `hermes-data`.
2. **Settings** → copy the **S3 API endpoint** (`https://<id>.r2.cloudflarestorage.com`).
3. **R2 Object Storage → API tokens → User API Tokens → Create API token**
   (leave IP filtering empty) → save **Access Key ID** + **Secret Access Key**.

## 2. OpenCode Zen key
- Get your API key from https://opencode.ai/zen (OpenCode ZEN key).
- Note the model you want, e.g. `deepseek-v4-flash` (a free Zen chat model).

## 3. GitHub
```bash
git add -A && git commit -m "Back4app-ready: bind \$PORT, R2 sync, OpenCode Zen" && git push
```

## 4. Back4app Containers
1. Sign up at https://www.back4app.com (free, **no credit card**).
2. **Containers → Create App** → connect GitHub repo `hermes-render` (branch `main`).
3. Dockerfile path: `./Dockerfile`. In app settings set the **Port** to the value Back4app
   shows as `$PORT` (the app also reads `$PORT` automatically).
4. Add **Environment Variables**:
   - `DASHBOARD_PASSWORD` — **required** (the script fails if missing; user = `admin`).
   - `R2_ENDPOINT`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `R2_BUCKET` (= `hermes-data`).
   - `OPENCODE_API_KEY` (or `OPENCODE_ZEN_KEY`) — your OpenCode Zen key.
   - `OPENCODE_BASE_URL` = `https://opencode.ai/zen/v1` (default).
   - `OPENCODE_MODEL` = `deepseek-v4-flash` (default, any Zen chat model).
5. Deploy. Back4app gives you a public URL.

## 5. First login
1. Open the URL → sign in with `admin` / your `DASHBOARD_PASSWORD`.
2. The dashboard **Models** page should show OpenCode Zen as the main model.
   If not, set provider = `custom`, base_url = `https://opencode.ai/zen/v1`, model = `deepseek-v4-flash`.
3. Use the dashboard (or `hermes gateway setup`) to connect Telegram etc.

## Notes / gotchas
- Free tier has **no persistent disk**, so R2 sync preserves state across redeploys.
- `sync.sh` runs every 5 min; a hard kill between syncs can lose <5 min of changes.
- 256 MB RAM is tight for dashboard + gateway; if it OOMs, bump to the $5 Shared plan (512 MB).
- OpenCode Zen uses pay-per-use billing — watch your Zen credits.

## Status (2026-08-23)

- Gateway-only deployment on Back4app Containers free tier
- Model: hy3-free via built-in opencode-zen provider (free SKU, no payment method)
- Interface: Telegram bot (no inbound ports needed)
