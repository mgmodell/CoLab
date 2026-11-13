# CoLab CTF — Gamified Penetration-Testing Competition

A hands-on, TryHackMe-style capture-the-flag built **into the real CoLab web app**.
Ten "rooms", each a genuine vulnerability embedded in CoLab's actual code — you
break into the live site with a real toolkit, capture a flag, and score points.
Use the hints and you lose points. It's a gamified version of a real penetration
test: the goal is to learn to **think and work like a pentester**, not to follow a
tutorial.

> **Authorized training only.** This is a deliberately-vulnerable copy of CoLab you
> run on your *own* machine for a supervised club event. Everything here is scoped
> to that local copy. Never point these techniques at a system you don't own or
> aren't authorized to test.

---

## Table of contents
1. [What you're playing](#what-youre-playing)
2. [The 10 rooms](#the-10-rooms)
3. [Setup guide](#setup-guide)  ← start here
4. [How to play](#how-to-play)
5. [Scoring & hints](#scoring--hints)
6. [The toolkit](#the-toolkit)
7. [Links](#links)
8. [Safety & isolation](#safety--isolation)

---

## What you're playing

Each student runs their **own local copy** of the whole thing: the real CoLab app
(with the vulnerabilities turned on) plus a Kali toolbox full of pentest tools.
You play in front of the instructor; at the end you open the **FINAL SCORE** screen
and your points decide the winner.

Every room is designed so it is **100% solvable by a human** using only:

1. the **toolkit** we ship (curl, jq, jwt_tool, ruby, python3, nmap, ffuf, …),
2. the **CoLab web app** in your browser, and
3. your **own knowledge**.

Nothing is handed to you. No secret is pre-dumped, no token is left lying around.
If a room needs a token cracked or a service reached, there's a legitimate in-scope
path to get there — exactly like a real engagement. The **hints** are the one place
hand-holding lives, and they cost points.

---

## The 10 rooms

Three Easy, four Medium, three Hard — **2,800 points** on the board.

| # | Room | Class | Difficulty | Pts | OWASP |
|---|------|-------|:---------:|:---:|:-----:|
| 1 | IDOR: Student Records | Broken access control | Easy | 100 | [A01][a01] |
| 2 | SQL Injection: Authentication Bypass | Injection | Easy | 100 | [A03][a03] |
| 3 | Sensitive Data Exposure: Verbose API Errors | Misconfiguration | Easy | 100 | [A05][a05] |
| 4 | Reflected XSS: Content Preview | Injection (XSS) | Medium | 250 | [A03][a03] |
| 5 | Broken Access Control: Mass-Assignment | Privilege escalation | Medium | 250 | [A01][a01] |
| 6 | CSRF: Account Recovery Email | Request forgery | Medium | 250 | [A01][a01] |
| 7 | Command Injection: Diagnostics Tool | Injection (OS cmd) | Medium | 250 | [A03][a03] |
| 8 | SSRF: Internal Service Pivot | Server-side request forgery | Hard | 500 | [A10][a10] |
| 9 | Insecure Deserialization: Unsigned Marshal RCE | Integrity failure | Hard | 500 | [A08][a08] |
| 10 | Auth Token Forgery: Weak-Secret JWT | Auth failure | Hard | 500 | [A07][a07] |

Each room maps to an OWASP Top 10 category (linked above) so you can read the theory
behind what you just exploited.

---

## Setup guide

You do the whole setup yourself, on your own machine — we never touch your computer.
The **first-time setup needs internet** (to pull/build the container images); after
that it runs **offline**. Plan for a one-time download of a few GB.

Everything below is **Windows + PowerShell**, which is the fully-supported path
(it auto-opens your browser to the live site). A Git Bash note is at the end.

> **This CTF runs on Podman — not Docker.** Every launcher calls `podman` directly,
> so you must install **Podman Desktop** (a free, daemonless Docker alternative).
> Docker Desktop will **not** run these scripts.

### Prerequisites (install once)

| You need | Why | Download |
|----------|-----|----------|
| **Podman Desktop** | **Required — Podman, not Docker.** Runs the containers; every launcher calls `podman`. | <https://podman-desktop.io/> |
| **Git** (incl. Git Bash) | Clone the repo; the launchers use Git Bash under the hood. | <https://git-scm.com/downloads> |
| **Google Chrome** | The launcher opens the live CoLab for you in Chrome. | <https://www.google.com/chrome/> |

After installing Podman Desktop, start its engine once:

```powershell
podman machine start
```

### Step 1 — Get the code

```powershell
git clone -b CTF https://github.com/mgmodell/CoLab.git CoLab
cd CoLab
```

That `-b CTF` checks out the **`CTF`** branch, which is the competition.

### Step 2 — Build the images (one-time, large)

```powershell
.\sec_serv.ps1 -Build      # the CoLab app + database + proxy
.\ctf_serv.ps1 -Build      # the Kali toolbox (~8 GB, one-time)
```

### Step 3 — Boot the target app

```powershell
.\sec_serv.ps1 -Up         # pick any mode at the prompt; wait for "Target is UP"
.\sec_serv.ps1 -Init       # load the database
.\sec_serv.ps1 -Seed       # seed accounts + data
```

When it's up the app is reachable at:

| URL | Use |
|-----|-----|
| <https://localhost:13443> | the site in your browser (accept the self-signed cert) |
| `http://localhost:13000` | direct HTTP for recon/tools |
| `http://app:3000` | the in-network address your toolkit attacks |

### Step 4 — Turn on the CTF vulnerabilities

```powershell
cd CTF\lab-setup
.\apply-embeds.ps1         # embeds rooms 2–10 into the real app
.\apply-box1.ps1           # embeds room 1 (student-records IDOR)
cd ..\..
```

> Re-run these two only if you ever **recreate** the app container — the
> vulnerabilities live in its writable layer and survive restarts.

### Step 5 — Play

```powershell
cd CTF
.\ctf_serv.ps1
```

Chrome opens on the live CoLab, and the game menu runs in your terminal. Pick a
room and go.

### Every time after that

```powershell
podman machine start       # if the engine is stopped
.\sec_serv.ps1 -Up         # if the app isn't already running
cd CTF ;  .\ctf_serv.ps1   # play
```

### Git Bash alternative

```bash
cd /c/Users/issia/CoLab/CTF && ./ctf_serv.sh
```

The Git Bash launcher runs the same game, but you open <https://localhost:13443>
in your browser yourself. On Windows, prefer the PowerShell launcher.

---

## How to play

Select a room number. Each room gives you:

1. **A briefing** — the attack type, your objective, and a free nudge toward the
   tools that help. It tells you *what* and *why* — never the solution.
2. **The live target** — your browser opens on the real CoLab page in scope, and
   your toolkit terminal can hit `http://app:3000` directly.
3. **A working directory** with a short recon note for that room.

Then work the room like a real finding: recon → find the flaw → exploit it →
retrieve the `CoLab{...}` flag → submit it.

Room menu: `[s]` submit flag · `[h]` hint · `[r]` reset room · `[i]` briefing · `[b]` back.

When you're done (or time's up), pick **`[f]` Complete CTF** from the menu for the
retro-arcade **FINAL SCORE** screen — that's what the instructor reads to score you.

---

## Scoring & hints

- **Points:** Easy 100 · Medium 250 · Hard 500 — **2,800 total**.
- **Hints cost points.** A room's points are split evenly across its hint steps.
  Each hint you reveal forfeits one step's share. Use **every** hint in a room and
  you score **0** for it — but you still capture the flag and clear the room.
- **That's the trade-off the game is about:** solve it on your own for full points,
  or buy help and give points back. The hints *will* walk you all the way to the
  answer if you need them.
- **Progress is saved** per player on your machine, so you can quit and resume.
- **FINAL SCORE** (`[f]`) shows your total, a letter rank, and a per-room breakdown.
  Highest score wins the event.

---

## The toolkit

Fundamentals only — the same tools a real tester reaches for first, all packaged
**inside** the CTF toolbox (nothing extra to install):

```
curl   jq   jwt_tool   ruby   python3   nmap   ffuf   base64   openssl   nc
```

Plus the classic **`rockyou.txt`** wordlist for cracking. There are deliberately
**no** one-button auto-exploiters (no sqlmap, hydra, or metasploit) — you do the
steps yourself, which is the whole point.

---

## Links

- **Podman Desktop** (container engine) — <https://podman-desktop.io/>
- **Git / Git Bash** — <https://git-scm.com/downloads>
- **Google Chrome** — <https://www.google.com/chrome/>
- **OWASP Top 10 (2021)** — <https://owasp.org/Top10/>
- Live app (after setup): **<https://localhost:13443>**

OWASP categories used in the rooms: [A01 Broken Access Control][a01] ·
[A03 Injection][a03] · [A05 Security Misconfiguration][a05] ·
[A07 Identification & Authentication Failures][a07] ·
[A08 Software & Data Integrity Failures][a08] ·
[A10 Server-Side Request Forgery][a10].

[a01]: https://owasp.org/Top10/A01_2021-Broken_Access_Control/
[a03]: https://owasp.org/Top10/A03_2021-Injection/
[a05]: https://owasp.org/Top10/A05_2021-Security_Misconfiguration/
[a07]: https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/
[a08]: https://owasp.org/Top10/A08_2021-Software_and_Data_Integrity_Failures/
[a10]: https://owasp.org/Top10/A10_2021-Server-Side_Request_Forgery_%28SSRF%29/

---

## Safety & isolation

- The app and toolbox run in **containers on an isolated network** on your own
  machine. Nothing is published to the internet.
- This is a **deliberately-vulnerable training copy** of CoLab — never the real,
  hardened production site.
- Run it only for the supervised event, and only against your own local copy.
