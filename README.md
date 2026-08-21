# Hermes Agent on Render (Free Tier)

Self-hosted Hermes Agent (gateway + web dashboard) on Render's **free** plan,
with persistent memory via Cloudflare R2 so redeploys don't wipe sessions/skills.

## What this repo deploys
- **gateway** — Telegram/Discord/etc. messaging + cron. Internal on `:8642`.
- **dashboard** — web UI on `:9119` (loopback only).
- **Caddy** — reverse proxy + HTTP basic auth on Render's public `$PORT`.
- **sync** — every 5 min pushes `/opt/data` to Cloudflare R2; restored on boot.

## 1. Cloudflare R2 (one-time)
1. Cloudflare dashboard → **R2** → create bucket `hermes-data`.
2. **Account details** → copy the **S3 API endpoint** (looks like `https://<id>.r2.cloudflarestorage.com`).
3. **API Tokens → R2 API Token** → create an Access Key (save ID + Secret).

## 2. GitHub
Push this repo to your account:
```
git init && git add -A && git commit -m "hermes render"
git remote add origin https://github.com/Youssef-Rezk-Mohammed/hermes-render.git
git push -u origin main
```

## 3. Render
1. New → **Web Service** → connect the repo.
2. Runtime: **Docker**, Plan: **Free**, Branch: `main`.
3. In **Environment**, fill the `sync: false` vars:
   - `DASHBOARD_PASSWORD` — pick a strong password (user = `admin`).
   - `R2_ENDPOINT`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `R2_BUCKET`.
   - `NOUS_PORTAL_TOKEN`, `GOOGLE_API_KEY`, `OPENCODE_ZEN_KEY`.
4. Deploy. Render gives you `https://hermes-agent.onrender.com`.

## 4. Keep it awake (free tier sleeps after 15 min)
Create a free **UptimeRobot** monitor (HTTP, every 5 min) pointing at your
Render URL. This keeps the 750 free hours spinning all month.

## 5. First login
1. Open the Render URL → enter basic-auth (`admin` / your password).
2. In the dashboard **Config**, set up providers:
   - **Nous Portal** (token = `NOUS_PORTAL_TOKEN`)
   - **Google AI Studio** (key = `GOOGLE_API_KEY`)
   - **OpenCode ZEN** (key = `OPENCODE_ZEN_KEY`) — confirm the exact provider name in `hermes model`.
3. `hermes gateway setup` (or dashboard) to connect Telegram etc.

## Notes / gotchas
- Free plan has **no persistent disk**, so R2 sync is what preserves state.
  If R2 is misconfigured, the agent still runs but starts "fresh" after redeploys.
- `sync.sh` runs every 5 min; a hard kill between syncs can lose <5 min of changes.
- Bandwidth cap on free = 5 GB/month (plenty for a Telegram bot).
