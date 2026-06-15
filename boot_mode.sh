#!/bin/bash
# ============================================================================
# boot_mode.sh — CoLab pentest lab engagement-mode selector.
#
# Runs at lab startup (called by sec_serv.sh -u, before the containers spin up)
# to set the "rules of engagement" for the session, the way a real engagement
# kicks off. It:
#
#   * shows the lab banner + target,
#   * prompts the operator to choose Black / White / Gray box,
#   * prompts for the tester's name (for the audit trail),
#   * writes the selected mode to containers/sec_env/.env so PENTEST_MODE is
#     passed into the pentest toolbox container (check with: echo $PENTEST_MODE),
#   * generates a timestamped sessions/SESSION_CONTEXT_<ts>.md (logged per boot),
#   * (re)generates the plain-text "CoLab Pentest Lab - Quick Start.txt",
#   * prints a mode briefing with a mode-specific recon checklist + tool order.
#
# REALISM: the briefing/Claude-assist context is GATED by mode. Black Box hides
# the stack (heroku-26 / Ruby / jemalloc / Node.js / MariaDB) — you earn that
# intel through recon. White Box unlocks the full stack + schema-assisted
# testing. Gray Box is a role-authenticated (student) scenario.
#
# Idempotent: re-running re-prompts and writes a fresh session file + .env.
# Bash + Podman (rootless) friendly. No Docker-specific anything.
#
# Non-interactive use (testing / doc refresh):
#   PENTEST_MODE_CHOICE=2 PENTEST_TESTER="Alice" ./boot_mode.sh   # skip prompts
#   ./boot_mode.sh --quickstart                                   # only regen txt
# ============================================================================
set -uo pipefail

# --- Resolve project root from this script's own location -------------------
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${PROJECT_ROOT}/containers/sec_env/.env"
SESSIONS_DIR="${PROJECT_ROOT}/sessions"
QUICKSTART_FILE="${PROJECT_ROOT}/CoLab Pentest Lab - Quick Start.txt"
TARGET_NAME="CoLab.online"

# --- Colors (terminal output ONLY — never written to the .md/.txt files) ----
if [ -t 1 ]; then
  C_RESET='\033[0m'; C_BOLD='\033[1m'; C_DIM='\033[2m'
  C_CYAN='\033[36m'; C_GREEN='\033[32m'; C_YELLOW='\033[33m'; C_RED='\033[31m'
else
  C_RESET=''; C_BOLD=''; C_DIM=''; C_CYAN=''; C_GREEN=''; C_YELLOW=''; C_RED=''
fi

# ---------------------------------------------------------------------------
# Plain-text Quick Start generator (Section 1 setup + Section 2 mode guide).
# No markdown, no ANSI — clean for any editor. Overwrites on every boot so it
# stays in sync with the project.
# ---------------------------------------------------------------------------
write_quickstart() {
  cat > "${QUICKSTART_FILE}" <<'QSEOF'
==============================================================================
  CoLab Pentest Lab  -  QUICK START
  Authorized FERPA confidentiality engagement against a CoLab.online replica
==============================================================================

What this is:
  An isolated, throwaway lab for the AUTHORIZED FERPA security test of CoLab.
  It runs four containers:
     app      = CoLab in PRODUCTION mode  (the target you test)
     db       = MariaDB                   (the student-data store)
     proxy    = Caddy TLS reverse proxy   (serves HTTPS, like the real site)
     pentest  = Kali Linux toolbox        (where you run the tools)

  Project folder:  C:\Users\issia\CoLab          (git branch: Sec)
  Target in browser:
     https://localhost:13443   <- USE THIS for login / full functionality (HTTPS,
                                  like the real site; accept the self-signed cert)
     http://localhost:13000    <- direct HTTP (recon/tools); login won't persist here

  This file is regenerated every time the lab boots (./sec_serv.sh -u) so it
  stays in sync with the project. Open it any time without launching the lab.


==============================================================================
SECTION 1  -  FULL LAB SETUP & STARTUP GUIDE
==============================================================================

------------------------------------------------------------------------------
  PREREQUISITES  (first time on a new machine)
------------------------------------------------------------------------------

  - Podman (rootless). Podman Desktop bundles the machine + compose provider.
       Windows : install Podman Desktop, then:  podman machine init
                                                podman machine start
       Linux   : sudo apt-get install -y podman podman-compose
       macOS   : brew install podman && podman machine init && podman machine start
  - VS Code + the "Dev Containers" (Remote - Containers) extension.
  - Git. Engagement branching workflow:   main  ->  Sec   (all work on 'Sec').
  - Helpful VS Code extensions: REST Client, GitLens.
  - Clone & checkout:
       git clone https://github.com/mgmodell/CoLab.git
       cd CoLab
       git checkout Sec
  - The stack ships with safe SANDBOX defaults baked into
    containers/sec_env/docker-compose.yml (DB creds prod/prod, a fixed sandbox
    SECRET_KEY_BASE), so no secrets are required to boot the lab.
  - Linux rootless only: make sure subuid/subgid ranges exist for your user:
       grep "$USER" /etc/subuid /etc/subgid
    If missing:
       sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
       podman system migrate


------------------------------------------------------------------------------
  IMPORTANT - WHERE TO RUN THE COMMANDS
------------------------------------------------------------------------------

Run everything from a HOST shell on Windows:
   * Git Bash, or
   * PowerShell / Windows Terminal

Do NOT run it from the VS Code "dev container" terminal (the one whose prompt
looks like  app git:(Sec) ). That terminal is INSIDE a container and has no
"podman", so you'll get:  ERROR: 'podman' was not found on PATH.

Quick check that you're in the right place (a HOST shell):
   podman --version          <- should print "podman version 5.x"


------------------------------------------------------------------------------
  STEP-BY-STEP: BOOT IT UP
------------------------------------------------------------------------------

1) Make sure Podman is running (needed after every reboot):
      podman machine start
   (Safe to run even if it's already started.)

2) Open a HOST shell and go to the project folder.
      Git Bash:     cd /c/Users/issia/CoLab
      PowerShell:   cd C:\Users\issia\CoLab

3) (First time only, or after pulling new changes) build the images.
   Large and slow the first time - several GB. Skip if the images already exist.
      Git Bash:     ./sec_serv.sh -b
      PowerShell:   .\sec_serv.ps1 -Build

4) Start the lab.
      Git Bash:     ./sec_serv.sh -u
      PowerShell:   .\sec_serv.ps1 -Up
   On the Git Bash path, -u FIRST runs the interactive ENGAGEMENT MODE SELECTOR
   (Black / White / Gray box - see Section 2), then brings the stack up. It waits
   and prints "Target is UP" when the site really answers (first boot runs
   database migrations - can take ~1 minute).

5) (Optional) Load / reset the database from db\dev_db.sql.
   Auto-migration already runs on boot; use this to load a snapshot or reset.
      Git Bash:     ./sec_serv.sh -i
      PowerShell:   .\sec_serv.ps1 -Init

6) Seed the site so it's POPULATED like the real thing - foundational data
   (~185 languages, countries/states, scenarios) PLUS the sandbox test accounts.
   Run once after a fresh start (and again after any -X wipe). Idempotent.
      Git Bash:     ./sec_serv.sh -e
      PowerShell:   .\sec_serv.ps1 -Seed

7) Open the target in your browser:
      https://localhost:13443       (accept the self-signed certificate warning)
   Log in with a sandbox account (below). (http://localhost:13000 is also up for
   recon tools, but login won't persist there: the app uses Secure cookies over
   HTTPS, just like the real site.)


------------------------------------------------------------------------------
  LOGIN ACCOUNTS (sandbox - intentionally weak, for the authorized test only)
------------------------------------------------------------------------------

  Created by step 6 (-e). Full list / source: C:\Users\issia\CoLab\db\seed_pentest_users.rb

     admin@colab.test        password        <- ADMIN
     instructor@colab.test   Spring2025!
     jdoe@colab.test         Password1
     msmith@colab.test       letmein
     tjones@colab.test       password
     rbrown@colab.test       colab2025

  Log in at  https://localhost:13443  with the email + password. The React app
  POSTs to /auth/sign_in (devise_token_auth) and gets a Bearer token. For tooling,
  capture/replay that request with Burp or OWASP ZAP. From INSIDE the toolbox you
  can also get a token directly:
     curl -s -X POST http://app:3000/auth/sign_in -H 'Content-Type: application/json' \
          -d '{"email":"jdoe@colab.test","password":"Password1"}' -D - | grep -i token


------------------------------------------------------------------------------
  USING THE TOOLBOX (run the actual tests)
------------------------------------------------------------------------------

Drop into the Kali toolbox (a shell with all the tools; briefing shown on entry):
      Git Bash:     ./sec_serv.sh -p
      PowerShell:   .\sec_serv.ps1 -Pentest

Inside the toolbox, the target is reachable as  http://app:3000 . Check your mode:
   echo $PENTEST_MODE                    # blackbox | whitebox | graybox

Some first commands to try:
   cat SCOPE.md                          # rules of engagement (read first)
   whatweb http://app:3000               # fingerprint the target
   nmap -sV -p3000 app                   # service scan (target web host)
   nmap -sn 10.89.1.0/24                 # discover the engagement hosts (ping scan)
   nuclei -u http://app:3000 -t http/exposures/ -t http/misconfiguration/
   ffuf -u http://app:3000/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -fs 2104
   gitleaks dir /opt/colab-src           # secret-scan the app source (read-only)
   exit                                  # leave the toolbox

   READY ON BOOT (no setup needed): nuclei templates are baked in (refresh with
   'nuclei -update-templates'); Metasploit's DB auto-starts (msfconsole ->
   db_status is connected). OpenVAS is on-demand: run 'gvm-prepare' once.

   HEADS-UP: the app is a React SPA and returns HTTP 200 for almost any path
   (it serves index.html as a catch-all). Filter content discovery by response
   SIZE, not status code - e.g.  ffuf ... -fs 2104  (the shell page size; confirm
   it with:  curl -s http://app:3000/ | wc -c ). Otherwise you get false hits.

Keep your notes/evidence in  /root/engagement  (it persists between runs).
Wordlists are in  /usr/share/seclists  and  /usr/share/wordlists .


------------------------------------------------------------------------------
  COMMAND REFERENCE
------------------------------------------------------------------------------

   ACTION                      Git Bash            PowerShell
   -------------------------   -----------------   ---------------------
   Build images                ./sec_serv.sh -b    .\sec_serv.ps1 -Build
   Start (up) + mode selector  ./sec_serv.sh -u    .\sec_serv.ps1 -Up
   Open the Kali toolbox       ./sec_serv.sh -p    .\sec_serv.ps1 -Pentest
   Initialise/reset the DB     ./sec_serv.sh -i    .\sec_serv.ps1 -Init
   Seed data + test users      ./sec_serv.sh -e    .\sec_serv.ps1 -Seed
   Status (list containers)    ./sec_serv.sh -s    .\sec_serv.ps1 -Status
   Follow logs                 ./sec_serv.sh -l    .\sec_serv.ps1 -Logs
   Rails console on target     ./sec_serv.sh -c    .\sec_serv.ps1 -Console
   MySQL session on target     ./sec_serv.sh -q    .\sec_serv.ps1 -Mysql
   Stop (keep data)            ./sec_serv.sh -k    .\sec_serv.ps1 -Stop
   Tear down (keep volumes)    ./sec_serv.sh -x    .\sec_serv.ps1 -Down
   Tear down + WIPE the DB     ./sec_serv.sh -X    .\sec_serv.ps1 -DownVolumes
   Full help                   ./sec_serv.sh -h    .\sec_serv.ps1 -Help

   NOTE: the engagement mode selector runs on the Git Bash path (sec_serv.sh -u).
   The PowerShell driver brings the stack up without the interactive selector.


------------------------------------------------------------------------------
  STOPPING
------------------------------------------------------------------------------

   Pause for now (data kept):     ./sec_serv.sh -k    (resume later with -u)
   Remove containers (data kept): ./sec_serv.sh -x
   Start completely fresh:        ./sec_serv.sh -X  then  -u  then  -e
                                  (-X wipes the sandbox DB + notes;
                                   -e repopulates the data + test accounts.
                                   A normal reboot keeps your data - no -e needed.)


------------------------------------------------------------------------------
  AFTER A REBOOT
------------------------------------------------------------------------------

   1) podman machine start
   2) cd C:\Users\issia\CoLab     (PowerShell)   or   cd /c/Users/issia/CoLab
   3) ./sec_serv.sh -u            (pick a mode; it waits and confirms "Target is UP")


------------------------------------------------------------------------------
  GITHUB AUDIT TRAIL
------------------------------------------------------------------------------

  After each session, commit your notes + findings to the engagement branch:
       git add sessions/ <your-evidence>
       git commit -m "session: <date> <mode> - <summary>"
       git push origin Sec
  Every boot writes a timestamped record under sessions/ - commit those so the
  engagement has a complete, dated audit trail.


------------------------------------------------------------------------------
  TROUBLESHOOTING
------------------------------------------------------------------------------

  * "'podman' was not found on PATH"
        You're in the VS Code dev-container terminal. Use a HOST shell
        (Git Bash or PowerShell). Check with:  podman --version

  * "cannot reach the Podman engine"
        The Podman machine is stopped (common after a reboot). Run:
        podman machine start     then try again.

  * "-Pentest / -p does nothing" or "container is not running"
        The lab containers stopped (after the PC sleeps or reboots - Podman
        doesn't always auto-restart them). sec_serv AUTO-STARTS the stack for
        -p/-c/-q, so just run the command again. If needed, run ./sec_serv.sh -u
        first (and  podman machine start  if the engine is down).

  * Browser shows nothing right after starting
        First boot takes ~1 minute (migrations). Wait for the "Target is UP"
        line, or check:  ./sec_serv.sh -s   and   ./sec_serv.sh -l

  * PowerShell says scripts are blocked
        Run once:  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

  * Check the target by hand:
        curl http://localhost:13000/up      (200 = healthy)


------------------------------------------------------------------------------
  NOTES
------------------------------------------------------------------------------

  * Only ever load SYNTHETIC / sanitised data into db\dev_db.sql - never a real
    student-data export. This is a throwaway sandbox.
  * Nessus (license) and OpenVAS/GVM feeds are NOT auto-enabled; OpenVAS sets up
    on demand via 'gvm-prepare'. Activation details are in the docs.
  * Full documentation: C:\Users\issia\CoLab\doc\PENTEST_ENV.md


==============================================================================
SECTION 2  -  BOOT MODE SELECTOR GUIDE
==============================================================================

Every './sec_serv.sh -u' launches an interactive selector that sets the rules
of engagement for the session. Pick the mode that matches the scenario you want
to train against.

MODE OVERVIEW
--------------------------------------------------------------------------------
[1] BLACK BOX   No prior knowledge. You are an external attacker.
                - No stack docs, no DB schema, no source code
                - Start with passive recon: DNS, OSINT, headers, fingerprinting
                - Tools: nmap, whatweb, theHarvester, Shodan, Burp/ZAP, ffuf
                - Claude AI-assist: recon-only guidance until intel is earned

[2] WHITE BOX   Full internal access. Source-assisted deep testing.
                - Stack known: heroku-26 / Ruby / jemalloc / Node.js / MariaDB
                - DB schema available, credentials in scope, source mounted
                - Tools: all of the above + sqlmap, source review, schema mapping,
                  gitleaks (against the read-only source at /opt/colab-src)
                - Claude AI-assist: full stack context, FERPA endpoint mapping,
                  schema-targeted SQL injection payloads

[3] GRAY BOX    Role-authenticated. You have a student account, nothing more.
                - No source, no admin, no schema
                - Focus: IDOR / BOLA, privilege escalation, auth bypass, sessions
                - Tools: Burp Suite, ffuf, jwt_tool, OWASP ZAP
                - Claude AI-assist: auth/authz focused, role-boundary testing
--------------------------------------------------------------------------------

WHAT GETS AUTO-GENERATED AT BOOT
   - sessions/SESSION_CONTEXT_<timestamp>.md
     A per-boot, timestamped record: selected mode, start time, tester name,
     scope reminder (ROE), the mode's recon checklist + tool order, and a
     ready-to-paste Claude AI-assist prompt header. Find it under sessions/.

USING THE CLAUDE AI-ASSIST PROMPT HEADER
   - Open the newest sessions/SESSION_CONTEXT_<timestamp>.md.
   - Copy the block under "CLAUDE AI-ASSIST PROMPT HEADER".
   - Paste it as the FIRST message in a new Claude session. It locks Claude into
     the correct mode context (e.g. recon-only for Black Box; full stack +
     schema for White Box) so the AI pair-operator stays in character.

CHECKING THE ACTIVE MODE
   - PENTEST_MODE is exported into the toolbox container. From inside it
     (./sec_serv.sh -p) confirm with:
                   echo $PENTEST_MODE
     -> blackbox | whitebox | graybox

RULES OF ENGAGEMENT (always in force)
   - IN SCOPE     : the CoLab.online web application replica (the 'app' target),
                    and the 'db' ONLY as reached THROUGH app weaknesses (to prove
                    impact) or for grey-box validation agreed with the data owner.
   - OUT OF SCOPE : third-party / host infrastructure, anything outside the
                    engagement network, and DoS / availability-impacting
                    techniques. This is a READ / CONFIDENTIALITY assessment.

==============================================================================
QSEOF
}

# ---------------------------------------------------------------------------
# --quickstart: regenerate only the plain-text Quick Start, then exit.
# ---------------------------------------------------------------------------
if [ "${1:-}" = "--quickstart" ]; then
  write_quickstart
  echo "Wrote: ${QUICKSTART_FILE}"
  exit 0
fi

# ---------------------------------------------------------------------------
# Banner.
# ---------------------------------------------------------------------------
print_banner() {
  # The CoLab "molecule/node" logo, drawn in the colors of the lab's node graphic
  # (cyan hub + magenta/green/red/orange/yellow satellites). Read into an array so
  # we can colorize per-character. The 'BANNER' heredoc is single-quoted so the
  # art's backticks/quotes/backslashes stay literal.
  local -a art
  mapfile -t art <<'BANNER'
   ____      _          _       ____            _            _
  / ___|___ | |    __ _| |__   |  _ \ ___ _ __ | |_ ___  ___| |_
 | |   / _ \| |   / _` | '_ \  | |_) / _ \ '_ \| __/ _ \/ __| __|
 | |__| (_) | |__| (_| | |_) | |  __/  __/ | | | ||  __/\__ \ |_
  \____\___/|_____\__,_|_.__/  |_|   \___|_| |_|\__\___||___/\__|
                          L A B   /   E N G A G E M E N T
BANNER

  # Truecolor palette sampled from the node graphic (R;G;B):
  #   magenta, red, orange, yellow, green, cyan.
  local -a pal=( '210;50;205' '215;55;50' '225;120;40' '245;225;60' '130;225;55' '120;255;230' )
  local plen=${#pal[@]} nlines=${#art[@]}
  local li c len ch idx out line

  printf "\n"
  if [ -t 1 ] && [ -z "${NO_BANNER_ANIM:-}" ]; then
    # Animated: roll the node colors across the letters (~1s). Redraws in place
    # by moving the cursor back up, so it doesn't flood the scrollback.
    local f frames=16
    for (( f=0; f<frames; f++ )); do
      (( f > 0 )) && printf '\033[%dA' "$nlines"
      for (( li=0; li<nlines; li++ )); do
        line="${art[li]}"; len=${#line}; out=""
        for (( c=0; c<len; c++ )); do
          ch="${line:c:1}"
          if [ "$ch" = " " ]; then out+=" "; continue; fi
          idx=$(( (c/2 + li + f) % plen ))
          out+=$'\033[1;38;2;'"${pal[idx]}"'m'"$ch"
        done
        printf '%s\033[0m\033[K\n' "$out"
      done
      sleep 0.06
    done
  elif [ -t 1 ]; then
    # Static colored fallback (terminal without animation, or NO_BANNER_ANIM=1).
    for (( li=0; li<nlines; li++ )); do
      line="${art[li]}"; len=${#line}; out=""
      for (( c=0; c<len; c++ )); do
        ch="${line:c:1}"
        if [ "$ch" = " " ]; then out+=" "; continue; fi
        idx=$(( (c/2 + li) % plen ))
        out+=$'\033[1;38;2;'"${pal[idx]}"'m'"$ch"
      done
      printf '%s\033[0m\n' "$out"
    done
  else
    # Not a terminal (piped/redirected): plain text, no escape codes.
    printf '%s\n' "${art[@]}"
  fi

  printf "\n"
  printf "  ${C_DIM}Authorized FERPA confidentiality engagement${C_RESET}\n"
  printf "  ${C_BOLD}Target:${C_RESET} ${C_GREEN}%s${C_RESET} (isolated container replica)\n\n" "${TARGET_NAME}"
}

# ---------------------------------------------------------------------------
# Mode selection.
# ---------------------------------------------------------------------------
print_menu() {
  printf "  ${C_BOLD}Select Pentest Mode:${C_RESET}\n"
  printf "    ${C_BOLD}[1] Black Box${C_RESET}  - No prior knowledge. Simulate an external attacker.\n"
  printf "    ${C_BOLD}[2] White Box${C_RESET}  - Full access to source, stack, and credentials.\n"
  printf "    ${C_BOLD}[3] Gray Box${C_RESET}   - Partial knowledge (role-based access, partial docs).\n\n"
}

CHOICE="${PENTEST_MODE_CHOICE:-}"
if [ -z "${CHOICE}" ]; then
  print_banner
  print_menu
  while true; do
    printf "  ${C_CYAN}Mode [1-3]: ${C_RESET}"
    read -r CHOICE
    case "${CHOICE}" in
      1|2|3) break ;;
      *) printf "  ${C_RED}Please enter 1, 2, or 3.${C_RESET}\n" ;;
    esac
  done
else
  print_banner
fi

# Tester name (audit trail).
TESTER="${PENTEST_TESTER:-}"
if [ -z "${TESTER}" ]; then
  printf "  ${C_CYAN}Tester name (for the audit trail): ${C_RESET}"
  read -r TESTER
fi
[ -z "${TESTER}" ] && TESTER="unnamed-operator"

# ---------------------------------------------------------------------------
# Map the choice to a mode and its (mode-gated) briefing content.
# ---------------------------------------------------------------------------
case "${CHOICE}" in
  1)
    MODE="blackbox"; MODE_LABEL="BLACK BOX"
    MODE_TAGLINE="No prior knowledge. You are an external attacker."
    INSCOPE_INTEL="Only what an outsider can observe. NO stack documentation, NO
DB schema, NO source code, NO credentials. Anything about the technology stack
must be DISCOVERED through recon before you rely on it."
    RECON_CHECKLIST="1. Passive OSINT  : public footprint, leaked creds, employee/role intel.
2. DNS            : records, subdomains, mail/SPF, hosting hints.
3. Transport      : TLS cert details + config (testssl.sh against the HTTPS edge).
4. HTTP surface   : response headers, cookies, security headers, error pages.
5. Fingerprinting : server/framework guesses from behaviour ONLY (whatweb -a3).
6. Content disc.  : routes/endpoints (filter the SPA catch-all by response SIZE).
   -> Only AFTER recon: move to authenticated/active testing as intel is earned."
    TOOL_SEQUENCE="theHarvester / Shodan (OSINT)  ->  dnsrecon / dig (DNS)  ->
testssl.sh (TLS)  ->  whatweb + curl -I (fingerprint/headers)  ->
ffuf / feroxbuster (content discovery, -fs to filter the SPA)  ->
Burp/ZAP proxy (manual probing once a surface is mapped)."
    CLAUDE_HEADER="You are my AI pair-operator on an AUTHORIZED FERPA penetration test of a
CoLab.online replica. ENGAGEMENT MODE: BLACK BOX.

Rules for you in this mode:
- Treat the target as an unknown external system. Do NOT reveal or assume the
  technology stack, framework, database engine, internal schema, file paths, or
  credentials. Do not name specific technologies unless I tell you I discovered
  them during recon.
- Guide me through PASSIVE recon FIRST (OSINT, DNS, TLS, HTTP headers,
  behavioural fingerprinting), THEN active/content discovery, and only then
  authenticated/exploitation steps as intel is earned.
- For each step give the concrete command and what to look for, mapped to OWASP
  WSTG / OSSTMM / ISSAF and to the FERPA confidentiality objective.
- Scope: the CoLab.online web app only; db only via app weaknesses. No DoS, no
  destructive actions. This is a read/confidentiality assessment."
    ;;
  2)
    MODE="whitebox"; MODE_LABEL="WHITE BOX"
    MODE_TAGLINE="Full internal access. Source-assisted deep testing."
    INSCOPE_INTEL="Everything. Stack is KNOWN: heroku-26 / Ruby / jemalloc /
Node.js / MariaDB. The application source is mounted read-only at /opt/colab-src
in the toolbox, the DB schema is available, and sandbox credentials are in
scope. Use it all to go deep and fast."
    RECON_CHECKLIST="1. Source review  : read /opt/colab-src — routes, controllers, models, authz.
2. Secret scan    : gitleaks dir /opt/colab-src (leaked keys/creds -> PII routes).
3. Schema mapping : enumerate the MariaDB schema; map FERPA-sensitive tables/cols.
4. Endpoint map   : derive student-data endpoints directly from routes/controllers.
5. Auth model     : devise_token_auth (Bearer) + role/authorization boundaries.
6. Targeted tests : schema-aware SQLi payloads, IDOR/BOLA on identified records,
                    TLS at the HTTPS edge, JWT/LTI claim validation."
    TOOL_SEQUENCE="source review + gitleaks (/opt/colab-src)  ->  schema mapping
(mariadb -h db -u prod -pprod colab_prod)  ->  route/endpoint mapping  ->
sqlmap (schema-targeted, READ-only techniques)  ->  curl/Burp (IDOR/authz)  ->
jwt_tool (LTI 1.3 claims)  ->  testssl.sh (transport)."
    CLAUDE_HEADER="You are my AI pair-operator on an AUTHORIZED FERPA penetration test of a
CoLab.online replica. ENGAGEMENT MODE: WHITE BOX.

Context you MAY use freely in this mode:
- Stack: heroku-26 / Ruby (Rails, Puma) / jemalloc / Node.js / MariaDB.
- Source is mounted read-only at /opt/colab-src; the DB schema and sandbox
  credentials are in scope. Auth is devise_token_auth (Bearer: access-token,
  client, uid headers).
Help me:
- Review the source to map controllers/routes/authorization and FERPA-sensitive
  data flows; identify which endpoints expose student PII.
- Map the MariaDB schema and write TARGETED, READ-ONLY SQL injection payloads
  against the real tables/columns to demonstrate confidentiality impact.
- Test IDOR/BOLA, role boundaries, JWT/LTI claim handling, and TLS config.
- Map every finding to OWASP WSTG / OSSTMM / ISSAF and the FERPA requirement it
  implicates. Scope: app + db (db via app or grey-box validation). No DoS, no
  destructive writes — this is a read/confidentiality assessment."
    ;;
  3)
    MODE="graybox"; MODE_LABEL="GRAY BOX"
    MODE_TAGLINE="Role-authenticated. You have a student account, nothing more."
    INSCOPE_INTEL="A single low-privilege STUDENT account and the application's
public/authenticated surface. NO source code, NO admin access, NO DB schema.
You know you are authenticated as a student; everything beyond your role must be
reached by testing, not by reading internals."
    RECON_CHECKLIST="1. Authenticate   : log in as the seeded student account; capture the token.
2. Map my access  : enumerate what the student role can legitimately see/do.
3. IDOR / BOLA     : vary object IDs to reach OTHER users' records (the #1 leak).
4. Privilege esc. : attempt student -> instructor/admin actions and endpoints.
5. Auth bypass    : forced browsing to privileged routes; missing function authz.
6. Session / JWT  : token handling, expiry, tampering, LTI claim trust (jwt_tool)."
    TOOL_SEQUENCE="login (curl to /auth/sign_in, capture access-token/client/uid)  ->
Burp/ZAP (intercept + replay as the student)  ->  ffuf (ID/parameter fuzzing for
IDOR)  ->  jwt_tool (token/claim tampering)  ->  manual forced-browsing to
privileged routes."
    CLAUDE_HEADER="You are my AI pair-operator on an AUTHORIZED FERPA penetration test of a
CoLab.online replica. ENGAGEMENT MODE: GRAY BOX (role-authenticated).

Assumptions for you in this mode:
- I hold ONE low-privilege STUDENT account. Do NOT assume or rely on source
  code, admin access, or internal DB schema — treat those as unknown.
- Auth is header-based (devise_token_auth: access-token, client, uid).
Focus our work on authorization, not infrastructure:
- Establish what my student role can legitimately do, then test the boundaries:
  IDOR/BOLA on other users' records, privilege escalation to instructor/admin,
  function-level auth bypass via forced browsing, and session/JWT/LTI claim
  tampering.
- For each, give the concrete request and what proves a finding, mapped to OWASP
  WSTG / OSSTMM / ISSAF and the FERPA confidentiality requirement. Scope: app +
  db via app weaknesses only. No DoS, no destructive actions."
    ;;
esac

# ---------------------------------------------------------------------------
# Timestamps / identifiers.
# ---------------------------------------------------------------------------
STAMP="$(date +%Y%m%d_%H%M%S)"
START_HUMAN="$(date '+%Y-%m-%d %H:%M:%S %Z')"
SESSION_FILE="${SESSIONS_DIR}/SESSION_CONTEXT_${STAMP}.md"

# ---------------------------------------------------------------------------
# Persist the mode for compose / the container session.
# containers/sec_env/.env is picked up for ${PENTEST_MODE} substitution, and
# sec_serv.sh sources it so podman compose passes it into the toolbox.
# ---------------------------------------------------------------------------
mkdir -p "$(dirname "${ENV_FILE}")"
cat > "${ENV_FILE}" <<ENVEOF
# Generated by boot_mode.sh — engagement session context for compose.
# Re-written on every './sec_serv.sh -u'. Safe to delete; defaults apply.
# Values are quoted so names with spaces survive shell sourcing.
PENTEST_MODE="${MODE}"
PENTEST_TESTER="${TESTER}"
PENTEST_SESSION="${STAMP}"
ENVEOF

# ---------------------------------------------------------------------------
# Per-boot session record (audit trail).
# ---------------------------------------------------------------------------
mkdir -p "${SESSIONS_DIR}"
cat > "${SESSION_FILE}" <<MDEOF
# CoLab Pentest — Session Context

| Field | Value |
|-------|-------|
| Engagement mode | **${MODE_LABEL}** (\`${MODE}\`) |
| Target | ${TARGET_NAME} (isolated container replica) |
| Session start | ${START_HUMAN} |
| Tester | ${TESTER} |
| Session id | ${STAMP} |
| Methodology | OWASP WSTG · OSSTMM · ISSAF |

## Mode — ${MODE_LABEL}
${MODE_TAGLINE}

### Intel in scope to reference in this mode
${INSCOPE_INTEL}

## Scope reminder (Rules of Engagement)
- **In scope:** the ${TARGET_NAME} web application replica (the \`app\` target),
  and the \`db\` **only** as reached *through* weaknesses in \`app\` (to prove
  impact) or for grey-box validation agreed with the data owner.
- **Out of scope:** third-party / host infrastructure, anything outside the
  engagement network, and **DoS / availability-impacting techniques**. This is a
  **read / confidentiality** assessment, not a stress test.

## Recon checklist (this mode)
\`\`\`
${RECON_CHECKLIST}
\`\`\`

## Recommended tool sequencing (this mode)
\`\`\`
${TOOL_SEQUENCE}
\`\`\`

## CLAUDE AI-ASSIST PROMPT HEADER
Copy everything in the block below and paste it as the **first message** in a new
Claude session to lock in ${MODE_LABEL} context for this engagement.

\`\`\`text
${CLAUDE_HEADER}
\`\`\`

---
*Auto-generated by boot_mode.sh at ${START_HUMAN}. Commit this file to branch \`Sec\` for the audit trail.*
MDEOF

# ---------------------------------------------------------------------------
# (Re)generate the plain-text Quick Start.
# ---------------------------------------------------------------------------
write_quickstart

# ---------------------------------------------------------------------------
# On-screen briefing (screenshot-friendly).
# ---------------------------------------------------------------------------
printf "\n"
printf "  ${C_GREEN}${C_BOLD}==============================================================${C_RESET}\n"
printf "  ${C_BOLD} ENGAGEMENT MODE: ${C_GREEN}%s${C_RESET}\n" "${MODE_LABEL}"
printf "  ${C_DIM} %s${C_RESET}\n" "${MODE_TAGLINE}"
printf "  ${C_GREEN}${C_BOLD}==============================================================${C_RESET}\n\n"
printf "  ${C_BOLD}Tester:${C_RESET}  %s\n" "${TESTER}"
printf "  ${C_BOLD}Started:${C_RESET} %s\n" "${START_HUMAN}"
printf "  ${C_BOLD}PENTEST_MODE:${C_RESET} ${C_CYAN}%s${C_RESET}  (echo \$PENTEST_MODE inside the toolbox)\n\n" "${MODE}"

printf "  ${C_BOLD}Intel in scope this mode${C_RESET}\n"
printf "%s\n\n" "${INSCOPE_INTEL}" | sed 's/^/    /'

printf "  ${C_BOLD}Recon checklist${C_RESET}\n"
printf "%s\n\n" "${RECON_CHECKLIST}" | sed 's/^/    /'

printf "  ${C_BOLD}Tool sequencing${C_RESET}\n"
printf "%s\n\n" "${TOOL_SEQUENCE}" | sed 's/^/    /'

printf "  ${C_YELLOW}Scope:${C_RESET} app + db(via app). ${C_RED}No DoS, no destructive actions${C_RESET} — read/confidentiality only.\n\n"

printf "  ${C_BOLD}Session logged:${C_RESET} %s\n" "${SESSION_FILE#${PROJECT_ROOT}/}"
printf "  ${C_DIM}  -> open it and paste the 'CLAUDE AI-ASSIST PROMPT HEADER' into a new Claude session.${C_RESET}\n"
printf "  ${C_BOLD}Quick Start:${C_RESET}    %s\n\n" "${QUICKSTART_FILE#${PROJECT_ROOT}/}"
