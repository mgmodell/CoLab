#!/usr/bin/env bash
# =============================================================================
#  Easy - SQL Injection: Authentication Bypass   (REAL CoLab app, toolkit)
#  CoLab's reporting-portal login builds its SQL by string-concatenating the
#  username/password - the classic auth-bypass SQL injection. The admin account's
#  password is random/unguessable, so the ONLY way in as admin is the injection.
#  Embedded by lab-setup/patch_sqli.rb + seed_sqli.rb (real controller + table).
#  NOTHING is handed to the player - they inject through the real login form.
# =============================================================================

sqli_provision() { return 0; }   # table + controller baked into the app image

sqli_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "NOTES.txt" \
"# Recon notes - CoLab reporting-portal login:
#     POST /api/portal/login   {username, password}   (JSON or form)
# You have a 'guest' account (guest / guest) to see a normal response. The admin
# account's password is unknown - the only way in as admin is the login form
# itself. Tools: curl, jq."
}

register_challenge \
  id="easy-sqli" \
  title="SQL Injection: Authentication Bypass - Easy" \
  diff="Easy" points="100" \
  owasp="A03:2021 Injection (SQLi)" \
  cvss="8.6 (AV:N/PR:N/C:H)" \
  slug="sqli_login_bypass" \
  finding="CoLab Pentest Report - login query built by string concatenation (authentication-bypass SQL injection)" \
  endpoint="POST /api/portal/login  {username,password}" \
  tools="curl,jq" \
  scenario="CoLab's reporting portal has a login. Behind it, the query that checks your credentials is built by pasting the username and password straight into a SQL string. You hold a low-privilege 'guest' account - but there's an 'admin' whose report you'd like to read, and you don't have their password." \
  objective="Bypass the login to authenticate as the admin account and read the flag it returns in the response." \
  remediation="Use parameterised queries / prepared statements; never concatenate user input into SQL; return generic authentication errors (don't echo DB errors)." \
  hints="Log in normally (guest/guest) to see the shape of the response, then put a single quote in the username field - does the reply leak a SQL error? That error means your input lands inside the query.
The check looks like  ... WHERE username = '<you>' AND password = '<you>'.  Make it always true to log in as the FIRST user:  username = ' OR '1'='1' --   (MySQL/MariaDB needs a SPACE after the --).
To land specifically on ADMIN, comment out the password check on the admin row:  username = admin' --   then read the 'note' field in the response - that's the admin's secret." \
  provision="sqli_provision" toolkit="sqli_toolkit" handler=""
