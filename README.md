# Madhuban Group — Website + Backend

A full-stack site for the **Madhuban Group** (*Shaping Futures Together*):

- **Frontend** — a modern, responsive multi-page site (plain HTML + Tailwind), 12 pages.
- **Backend** — a Node.js/Express app that serves the site, receives the **Enquiry**, **Contact** and **Careers** forms, stores every lead in a SQLite database, emails your team, and gives you a **password-protected admin dashboard** (view/search leads, mark handled, download CVs).

---

## 1. Quick start

You need [Node.js](https://nodejs.org) 18+ (tested on Node 24).

**Easiest (Windows): double-click `run.bat`.** It installs dependencies on first run, creates your `.env`, starts the server in its own window, and opens the site in your browser. Close that window to stop the site.

**Or from a terminal:**

```bash
# 1. install dependencies
npm install

# 2. create your config from the template
copy .env.example .env        # Windows
# cp .env.example .env         # macOS/Linux
#   → then open .env and set ADMIN_PASSWORD and SESSION_SECRET

# 3. run
npm start          # or: npm run dev  (auto-restarts on changes)
```

Stop the server with **Ctrl+C**.

Then open:

| URL | What |
|-----|------|
| http://localhost:3000 | The website |
| http://localhost:3000/admin | Admin dashboard (log in with `ADMIN_USER` / `ADMIN_PASSWORD` from `.env`) |

> **Dev mode with auto-restart:** `npm run dev` (restarts on file changes).

### Two ways to view the site
- **Full (recommended):** run `npm start` and visit `http://localhost:3000` — forms actually save & email.
- **Preview only:** double-click `public/index.html`. It opens with no server, so forms run in **“demo mode”** (they show a confirmation but don’t save). Useful for a quick look.

---

## 2. Project structure

```
Madhuban Website/
├── public/                 ← the website (served by Express, safe to expose)
│   ├── index.html + 11 pages
│   └── css/  js/  images/
├── server/                 ← backend (never web-served)
│   ├── server.js           ← Express app: routes, security, uploads
│   ├── db.js               ← SQLite schema + queries (better-sqlite3)
│   ├── mailer.js           ← email notifications (nodemailer)
│   ├── validate.js         ← input validation + honeypot
│   ├── views/render.js     ← admin dashboard HTML (XSS-escaped)
│   └── uploads/            ← applicant CV files (git-ignored)
├── data/
│   └── madhuban.db         ← SQLite database of all leads (git-ignored)
├── .env                    ← YOUR secrets (git-ignored — never commit)
├── .env.example            ← template
└── package.json
```

**Why the split?** Only `public/` is served to browsers, so your `.env`, database, source code and uploaded CVs are never downloadable. (Verified: requesting `/.env`, `/server/server.js` or `/data/madhuban.db` returns 404.)

---

## 3. The admin dashboard

Log in at `/admin`. You get:

- **Stat tiles** — total, new/unread, and counts per form type.
- **Tabs & search** — filter by Enquiries / Contact / Applications, by status (new/handled), and free-text search across name, email, phone and message.
- **Per-lead card** — all submitted fields, contact links (click to email/call), timestamp, and:
  - **Mark handled / new**
  - **Download CV** (for job applications)
  - **Delete** (also removes the CV file)

Actions are protected with a CSRF token and require a logged-in session (8-hour expiry).

---

## 4. Email notifications (optional)

Email is **optional** — if you don’t configure SMTP, submissions are **still saved** and appear in the dashboard; only the email alert is skipped.

To enable, set these in `.env`:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=youraddress@gmail.com
SMTP_PASS=your-app-password        # Gmail: create an "App Password"
NOTIFY_TO=contact@madhuban.biz     # where new-lead alerts go
SEND_AUTOREPLY=true                # also acknowledge the person who submitted
```

The server logs `SMTP ready — email alerts enabled` on start when it’s working.

---

## 5. API reference

| Method | Endpoint | Body | Purpose |
|--------|----------|------|---------|
| POST | `/api/enquiry` | urlencoded | Enquire-Now modal |
| POST | `/api/contact` | urlencoded | Contact page form |
| POST | `/api/careers` | multipart (incl. `cv` file) | Careers application |
| GET | `/api/health` | — | Public liveness (`{ ok: true }` only) |
| GET | `/admin/health` | — | Auth-only: mail status + lead counts |

All accept a hidden `website` honeypot field (spam bots fill it → silently discarded). CV uploads accept **PDF / DOC / DOCX up to 5 MB**. Form endpoints are rate-limited (30 requests / 15 min per IP). The admin dashboard is paginated (25 per page).

---

## 6. Deploying to production

Works on any Node host (Render, Railway, a VPS, etc.). Before going live:

1. **Set strong secrets** in the host’s environment: `ADMIN_PASSWORD`, and a random `SESSION_SECRET`
   (`node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`).
2. **Serve over HTTPS**, then set `COOKIE_SECURE=true` and (if behind a proxy/load balancer) `TRUST_PROXY=1`.
3. **Persistent storage.** On hosts with ephemeral disks (Render/Railway/containers), a redeploy wipes local files. Attach a persistent disk/volume and point `DATA_DIR` and `UPLOAD_DIR` at it, or your leads and CVs will be lost on each deploy.
4. **Back up** the database (`DATA_DIR/madhuban.db`) and CVs (`UPLOAD_DIR`) regularly — that’s all your leads and applications.
5. `NODE_ENV=production` (this also enforces strong secrets and secure cookies at startup — the server refuses to boot with placeholder credentials).
6. Optional: once you switch the frontend from the Tailwind CDN to a compiled CSS file, set `ENABLE_CSP=true` for a stricter Content-Security-Policy. (The admin dashboard already gets a strict CSP automatically.)

> Deploy tip: on hosts that can’t compile native modules, `better-sqlite3` ships prebuilt binaries for common Node versions, so `npm install` normally just works.

---

## 7. Frontend notes (unchanged)

- Nav links, phone, email, WhatsApp and footer live in one place: **`public/js/components.js`** (`CONTACT`, `NAV`, `EXPERTISE`).
- Brand colours/fonts: CSS variables at the top of **`public/css/styles.css`**.
- Logo: `public/images/madhuban-logo.png` (white PNG, darkened via CSS on light backgrounds).
- Leadership photos live in `public/images/` (`anil-dhawale-founder.jpg`, `anil-dhawale-headshot.jpg`, `anil-dhawale-office.jpg`, `prarthi-dhawale-bhambere-portrait.jpg`, plus full-frame originals). Mr. Parth Dhawale's card on `about.html` still uses a monogram placeholder until a photo is supplied.
- **Before public launch:** replace the Unsplash placeholder photos (search for `images.unsplash.com`) with the company’s own licensed images, and swap the text client “logos” for real logo files.

---

## 8. Data & privacy

Leads and CVs are **personal data**. The database (`data/`) and uploads (`server/uploads/`) are git-ignored so they’re never committed. Keep backups private, and delete data you no longer need from the dashboard.
