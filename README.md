# Hermes Agent on Back4app Containers (Free, No Credit Card) — powered by Google AI Studio (Gemini)

Self-hosted Hermes Agent (gateway-only) on **Back4app Containers** free tier,
with persistent memory via Cloudflare R2 so redeploys don't wipe sessions/skills.
The LLM is **Google AI Studio (Gemini)** — the only provider key you need.

> Why Back4app: free tier needs **no credit card**, gives **256 MB RAM / 0.25 CPU / 100 GB transfer**,
> and **does not force your container to sleep**. It assigns a `$PORT` env var and routes traffic there.

## What this repo deploys
- The **official Hermes image's own s6 init** (`/init`, the inherited ENTRYPOINT) supervises
  the gateway (`:8642`) and a static health page (bound to Back4app's `$PORT` on `0.0.0.0`).
- A `cont-init.d` script runs at boot: restores `/opt/data` from R2, writes
  `/opt/data/config.yaml` with the built-in gemini provider, and starts
  the R2 sync loop.
- No supervisord, no ENTRYPOINT override — we let the image manage its own lifecycle.

## 1. Cloudflare R2 (one-time, no card)
1. Cloudflare dashboard → **R2 Object Storage** → create bucket `hermes-data`.
2. **Settings** → copy the **S3 API endpoint** (`https://<id>.r2.cloudflarestorage.com`).
3. **R2 Object Storage → API tokens → User API Tokens → Create API token**
   (leave IP filtering empty) → save **Access Key ID** + **Secret Access Key**.

## 2. Google AI Studio key
- Get your API key from https://aistudio.google.com/apikey. Free, no credit card.
- Note the model default and the GEMINI_MODEL override.

## 3. GitHub
```bash
git add -A && git commit -m "Back4app-ready: bind \$PORT, R2 sync, Gemini" && git push
```

## 4. Back4app Containers
1. Sign up at https://www.back4app.com (free, **no credit card**).
2. **Containers → Create App** → connect GitHub repo `hermes-render` (branch `main`).
3. Dockerfile path: `./Dockerfile`. In app settings set the **Port** to the value Back4app
   shows as `$PORT` (the app also reads `$PORT` automatically).
4. Add **Environment Variables**:
   - `TELEGRAM_BOT_TOKEN` — **required** to use the Telegram interface.
   - `R2_ENDPOINT`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `R2_BUCKET` (= `hermes-data`).
   - `GEMINI_API_KEY` (or `GOOGLE_API_KEY`) — your Google AI Studio key.
   - `GEMINI_MODEL` = `gemini-3.6-flash` (default; set e.g. `gemini-3.7-flash` or a pro model to override).
5. Deploy. Back4app gives you a public URL.

## 5. First use
1. Open the Back4app public URL. You should see a "hermes gateway running" health page.
2. If you haven't already, set `TELEGRAM_BOT_TOKEN` in the Back4app environment variables.
3. Talk to your Telegram bot. The gateway will answer.

## Notes / gotchas
- Free tier has **no persistent disk**, so R2 sync preserves state across redeploys.
- `sync.sh` runs every 5 min; a hard kill between syncs can lose <5 min of changes.
- AI Studio free tier has per-minute/per-day rate limits — when exceeded the API returns 429 errors; it never auto-charges (paid usage requires explicitly linking a billing account in Google AI Studio).

## Status (2026-09-14)

- Gateway-only deployment on Back4app Containers free tier
- Model: gemini-3.6-flash via built-in gemini provider (AI Studio free tier, no payment method)
- Interface: Telegram bot (no inbound ports needed)
- Redeployed cleanly at 09:45 UTC after polling-conflict resolution (single-instance confirmed)
