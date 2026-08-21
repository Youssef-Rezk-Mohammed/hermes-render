# Hermes Agent on Render (Free Tier) — powered by OpenCode Zen

Self-hosted Hermes Agent (gateway + web dashboard) on Render's **free** plan,
with persistent memory via Cloudflare R2 so redeploys don't wipe sessions/skills.
The LLM is **OpenCode Zen** (an OpenAI-compatible gateway) — the only provider key you need.

## What this repo deploys
- **gateway** — Telegram/Discord/etc. messaging + cron. Internal on `:8642`.
- **dashboard** — web UI on `:9119` (loopback only).
- **Caddy** — reverse proxy + HTTP basic auth on Render's public `$PORT`.
- **sync** — every 5 min pushes `/opt/data` to Cloudflare R2; restored on boot.
- **start.sh** — seeds `~/.hermes/config.yaml` (i.e. `/opt/data/config.yaml`) with the
  OpenCode Zen endpoint so the agent has a working LLM on first boot.

## 1. Cloudflare R2 (one-time, no card)
1. Cloudflare dashboard → **R2 Object Storage** → create bucket `hermes-data`.
2. **Settings** → copy the **S3 API endpoint** (`https://<id>.r2.cloudflarestorage.com`).
3. **R2 Object Storage → API tokens → User API Tokens → Create API token**
   (leave IP filtering empty) → save **Access Key ID** + **Secret Access Key**.

## 2. OpenCode Zen key
- Get your API key from https://opencode.ai/zen (OpenCode ZEN key).
- Note the model you want, e.g. `deepseek-v4-flash` (a free Zen chat model).

## 3. GitHub
```
git add -A && git commit -m "use OpenCode Zen as the LLM" && git push
```

## 4. Render
1. New → **Web Service** → connect the repo.
2. Runtime: **Docker**, Plan: **Free**, Branch: `main`.
3. In **Environment**, fill the `sync: false` vars:
   - `DASHBOARD_PASSWORD` — pick a strong password (user = `admin`).
   - `R2_ENDPOINT`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `R2_BUCKET` (= `hermes-data`).
   - `OPENCODE_API_KEY` — your OpenCode Zen key.
   - `OPENCODE_BASE_URL` (default `https://opencode.ai/zen/v1`) — leave as-is.
   - `OPENCODE_MODEL` (default `deepseek-v4-flash`) — any Zen chat model.
4. Deploy. Render gives you `https://hermes-agent.onrender.com`.

## 5. Keep it awake (free tier sleeps after 15 min)
Create a free **UptimeRobot** monitor (HTTP, every 5 min) on your Render URL.
This keeps the 750 free hours spinning all month.

## 6. First login
1. Open the Render URL → enter basic-auth (`admin` / your password).
2. The dashboard **Models** page should already show OpenCode Zen as the main model.
   If not, run inside the container or dashboard: set provider = `custom`,
   base_url = `https://opencode.ai/zen/v1`, model = `deepseek-v4-flash`.
3. `hermes gateway setup` (or dashboard) to connect Telegram etc.

## Notes / gotchas
- Free plan has **no persistent disk**, so R2 sync is what preserves state.
  If R2 is misconfigured, the agent still runs but starts "fresh" after redeploys.
- `sync.sh` runs every 5 min; a hard kill between syncs can lose <5 min of changes.
- Bandwidth cap on free = 5 GB/month (plenty for a Telegram bot).
- OpenCode Zen uses pay-per-use billing — watch your Zen usage/credits.
