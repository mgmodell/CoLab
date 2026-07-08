# CoLab CTF — Gamified Training Range

A self-contained, TryHackMe-style capture-the-flag mode built from the
vulnerabilities documented in our CoLab.online penetration test (SURE program,
faculty-supervised, FERPA-scoped). It is **completely separate** from the
Black/White/Gray box ("Sec") engagement boot: it never runs `boot_mode.sh`,
never writes `containers/sec_env/.env`, and never boots the app/db/proxy target
stack. Everything lives under `CTF/` and is launched by its own `ctf_serv.sh`.

See **`CoLab CTF - Quick Start.txt`** for the full startup guide.

---

## Launching

From a HOST shell (Git Bash / PowerShell → run `./CTF/ctf_serv.sh` from Git Bash):

```bash
cd /c/Users/issia/CoLab/CTF

./ctf_serv.sh            # launch the CTF INSIDE the Sec Kali toolbox (full toolkit)
./ctf_serv.sh -p        # drop into the Kali toolbox shell (CTF at /opt/ctf)
./ctf_serv.sh -H        # run the CTF directly on the host (no container)
./ctf_serv.sh -x        # tear down the CTF container + internal network
./ctf_serv.sh -b        # (re)build the toolbox image (reuses the Sec Dockerfile)
./ctf_serv.sh -h        # help
```

Default mode reuses the **`colab_pentest`** Kali image (the same toolkit as the
Sec engagement — curl, sqlmap, jwt_tool, ffuf, gitleaks, nuclei, nmap, python3,
jq …), on its own isolated `--internal` network, with `CTF/` bind-mounted
writable at `/opt/ctf`. If podman or the image isn't available it automatically
falls back to host mode. You can also run the menu directly with `bash CTF/ctf.sh`.

> Requires `bash` + one of `sha256sum` / `shasum` / `openssl`. The toolbox path
> additionally needs podman (machine started) and the `colab_pentest` image.

---

## Booting the toolkit & the site

Two separate things you can start. **For the CTF you only need the toolkit** — the
challenge targets are offline mocks, so the CoLab *site* does **not** need to run.
Booting the real site is optional (for the Sec engagement, or to poke at the real
app). The CTF and the Sec engagement are independent — `ctf_serv.sh` never boots
or touches the site.

### 1) The toolkit (Kali toolbox) — needed for the CTF

One command boots the toolkit in **podman** and drops you into the CTF:

```bash
# Git Bash
cd /c/Users/issia/CoLab/CTF && ./ctf_serv.sh
# PowerShell
cd C:\Users\issia\CoLab\CTF ;  .\ctf_serv.ps1
```

- First time only: make sure Podman Desktop is installed and build the image once
  with `./ctf_serv.sh -b` (or reuse the Sec lab's `./sec_serv.sh -b`). `ctf_serv`
  auto-starts the podman machine if it's stopped.
- Want just the Kali shell (tools, no menu)? `./ctf_serv.sh -p`
  (`.\ctf_serv.ps1 -Shell`). The CTF is at `/opt/ctf`; run `./ctf.sh` to play.
- Check readiness: `./ctf_serv.sh -s` (`.\ctf_serv.ps1 -Status`).

### 2) The site (the real CoLab target) — optional, via the Sec lab

The CTF does not use the site. If you also want the real CoLab app running, boot it
with the **Sec** driver from the repo root (`C:\Users\issia\CoLab`):

```bash
podman machine start                 # if the engine is stopped
cd /c/Users/issia/CoLab
./sec_serv.sh -u                     # PowerShell: .\sec_serv.ps1 -Up
#   -> runs the Black/White/Gray mode selector, then brings app/db/proxy up
./sec_serv.sh -e                     # first run: seed data + sandbox test users
./sec_serv.sh -p                     # open the Sec Kali toolbox against the site
```

Site URLs once it's up:

| URL | Use |
|-----|-----|
| `https://localhost:13443` | login / full app (HTTPS — accept the self-signed cert) |
| `http://localhost:13000`  | direct HTTP (recon/tools; login won't persist here) |
| `http://app:3000`         | in-network address (from inside the toolbox) |

**Which do I want?**
- Play the vulns as a game → **toolkit only** (`./ctf_serv.sh`). No site needed.
- Test the real app → **Sec lab** (`./sec_serv.sh -u` for the site, `-p` for the toolbox).

---

## Challenge roster (10)

| # | Room | OWASP | Pts | Report ref |
|---|------|-------|-----|------------|
| 1 | IDOR: Grade Record Access — Easy | A01 | 100 | fragile read-path authz |
| 2 | Stored XSS: Course Comments — Easy | A03 | 100 | teaching (XSS held up) |
| 3 | Sensitive Data Exposure: Verbose API Errors — Easy | A05/A04 | 100 | secrets + debug errors |
| 4 | SQL Injection: Search Endpoint — Medium | A03 | 250 | teaching (SQLi held up) |
| 5 | Broken Access Control: Instructor Panel — Medium | A01 | 250 | **mass-assignment researcher (CVSS 7.1)** |
| 6 | CSRF: Account Email Change — Medium | A01 | 250 | account-update / takeover path |
| 7 | Server-Side Template Injection: Report Generator — Hard | A03 | 500 | teaching (SSTI held up) |
| 8 | Insecure Deserialization: Session Cookie — Hard | A08 | 500 | teaching |
| 9 | Bearer Token Forgery: Auth Bypass — Hard | A07 | 500 | teaching (token forgery held up) |
| 10 | **SSRF: Internal Service Pivot — Critical** | A10 | 1000 | **Check 07 — SSRF `/lti/tool_connect`, CVSS 9.3** |

The **Critical SSRF is the real engagement finding**: `POST /lti/tool_connect`,
unauthenticated, no allow-list. The flag sits on an internal-only cloud-metadata
service reachable **only** by pivoting the SSRF through the lab's internal
network (`169.254.169.254` → role creds) — mirroring Report Chain A.

Rooms 5 and 6 map to real findings (mass-assignment self-promotion; account-update
CSRF/takeover). Rooms 2, 4, 7, 8, 9 are **teaching rooms** for classes that were
*tested and hardened* in the real engagement — the CTF target is a separate,
deliberately-vulnerable app, not the hardened production stack.

---

## Playing a room

Select a number. Each room:

1. **Briefing** — scenario, vulnerability class, objective, OWASP mapping, CVSS,
   report reference, and a difficulty/points badge.
2. **Provision** — resets the target to a clean state, enables *only* that room's
   vulnerability, and plants that room's flag where it's reachable only by
   exploiting the bug.
3. **Toolkit** — stages a per-room working dir with `./colab-http` (a curl-ish
   client for the isolated target), an `OBJECTIVE.txt`, a `HINTS.txt`, any
   room-specific helpers (JWT forger, cookie forger, SSRF harness, sqli
   cheatsheet, CSRF PoC), and a `WRITEUP.md` template.

Then use the room menu: `[s]` submit · `[h]` hint · `[r]` reset · `[w]` writeup ·
`[i]` briefing · `[b]` back.

```bash
# example (IDOR room working dir):
cd CTF/state/work/easy-idor
./colab-http GET /api/grades/1337
```

### Toolkit menu & the live attack target

The main menu has a **`[t] toolkit`** entry and shows a **`TARGET`** line, e.g.
`TARGET http://10.88.0.3:8000`. That's a **real HTTP service** (started
automatically inside the toolbox) that serves whichever room you currently have
open — so the Sec tools work against a genuine `IP:port`, TryHackMe-style:

```bash
curl http://10.88.0.3:8000/api/grades/1337                       # IDOR (room 1)
curl "http://10.88.0.3:8000/api/search?q=x' UNION SELECT flag FROM secrets-- "  # SQLi (room 4)
sqlmap -u "http://10.88.0.3:8000/api/search?q=1" --batch          # room 4, automated
nmap -sV -p8000 10.88.0.3                                         # it's a real port
```

- The `[t] toolkit` screen lists the available tools (curl, sqlmap, jwt_tool,
  ffuf, gitleaks, nuclei, nmap, jq, base64) with ✓/○ availability, an example
  command against the current target, and `[s]` to drop into a Kali shell.
- The target IP is the toolbox container's address on the isolated internal
  network (plus `http://127.0.0.1:8000` from inside). It serves the **open**
  room; at the main menu it shows a landing page.
- `./colab-http` still works too (offline, no IP needed). If `python3` isn't
  available the live target is skipped and you use `./colab-http` only.

---

## Flags & verification

- Format: `CoLab{lowercase_snake_case}`.
- **No plaintext flags are stored in the repo.** `CTF/flags/flag-hashes.txt`
  holds **SHA-256 hashes only**. Plaintext is generated at first launch into
  `CTF/state/flags.plain` (gitignored, `chmod 600`) and used only to plant
  targets. Submissions are verified by hashing your input and comparing to the
  stored hash.
- Submit from the room menu (`[s]`), paste the flag, done.

---

## Scoring, hints, progress

- **Points:** Easy 100 · Medium 250 · Hard 500 · Critical 1000 (total **3550**).
  A TryHackMe-style running score shows in the menu header.
- **Hints:** 2–3 progressive hints per room, revealed on request; each reveal
  reduces that room's award (Easy −15 · Medium −35 · Hard −70 · Critical −140),
  floored at 40% of base.
- **Progress:** persisted to `CTF/state/progress.tsv` (+ a readable
  `progress.json` snapshot) — captured flags, points, hints used, and capture
  time per room. The menu shows `[✓]` markers and the running score.
- **Writeups:** after a capture you're offered a scratch `WRITEUP.md`
  (vuln / steps / payload / remediation) to journal the solve.

---

## Reset / teardown

- Per-room `[r]` — re-provisions a fresh target and clears that room's progress
  (replayable).
- Menu `[a]` — reset all progress + re-provision every room.
- Menu `[t]` — tear down all targets and the internal network (progress kept).

---

## Isolation guarantees

- Targets live **only** on an `--internal` Podman network (`colab_ctf_net`) with
  **no host port publishing** — reachable solely from the lab's pentest
  container, never the host or outside world, and never real CoLab
  infrastructure.
- By default the launcher **does not execute** container commands (so it can't
  hang on a stopped podman machine and is safe to run anywhere): it prints the
  exact podman commands the real lab would run and serves an **offline,
  network-free mock target** under `CTF/state/`, which is what the flag-capture
  logic runs against. Set `CTF_LIVE_PODMAN=1` inside the real lab to execute the
  container path.

---

## Adding a challenge (modular)

Drop a new file in `CTF/challenges/` (numeric prefix controls menu order) that:

1. Defines its `*_provision`, optional `*_toolkit`, and `*_handle` functions.
2. Calls `register_challenge` with `key=value` metadata (id, title, diff, points,
   penalty, owasp, cvss, slug, tools, scenario, objective, endpoint,
   remediation, finding, hints, provision, toolkit, handler).

`ctf.sh` auto-discovers `challenges/*.sh`; the menu, flag seed, scoring, and
progress all key off the registry. No other file needs editing.

```
CTF/
  ctf_serv.sh            # startup: runs the CTF in the Kali toolbox (or --host)
  ctf.sh                 # the range itself: menu + hidden __serve dispatcher
  CoLab CTF - Quick Start.txt   # startup guide
  lib/                   # ui, banner, flags, state, provision, toolkit, mockweb
  challenges/            # 00-common.sh (framework) + one file per room
  flags/flag-hashes.txt  # SHA-256 hashes only
  state/                 # runtime (gitignored): progress, flags.plain, targets, work
```
