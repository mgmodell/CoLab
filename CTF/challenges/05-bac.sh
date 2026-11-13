#!/usr/bin/env bash
# =============================================================================
#  Medium - Broken Access Control: mass-assignment self-promotion  (REAL CoLab)
#  As a plain student you are blocked (HTTP 302) from staff-only course views
#  (check_viewer = admin/instructor/researcher). But CoLab's account-update
#  strong-params PERMIT the `researcher` attribute
#  (ApplicationController#configure_permitted_parameters), and is_researcher?
#  just reads that column. So a student PUTs {"researcher":true} to /auth and
#  instantly becomes a viewer - then reads the staff course the flag hides in.
#
#  TRAINING PLATFORM: nothing faked - the over-permissive strong-param is real
#  CoLab. We only plant a plain student account + a staff course whose
#  description holds the flag (CTF/lab-setup/seed_bac.rb), visible ONLY to a
#  viewer. Multi-step -> solved from the toolkit terminal with curl.
# =============================================================================

bac_provision() { return 0; }   # account + staff course seeded out-of-band (apply-embeds.ps1)

bac_toolkit() {
  local id="$1"
  toolkit_install_helper "$id" "NOTES.txt" \
"# Recon notes - broken access control / mass assignment:
#   You have a student login:  student-bac@colab.test / Password1
#   Log in:  POST /auth/sign_in {email,password}
#            -> returns devise auth headers (access-token, client, uid) to send
#               on every later request.
#   Staff-only course (flag hides in its description):  GET /api-backend/courses/4.json
#   Account update:  PUT /auth   (binds JSON fields straight onto your account)
# Tools: curl, jq."
}

register_challenge \
  id="med-bac" \
  title="Broken Access Control: Mass-Assignment - Medium" \
  diff="Medium" points="250" penalty="35" \
  owasp="A01:2021 Broken Access Control (mass assignment)" \
  cvss="7.1 (AV:N/PR:L)" \
  slug="researcher_role_selfgrant" \
  finding="CoLab Pentest Report Check 08/10 - over-permissive account_update strong-params (researcher self-grant)" \
  endpoint="PUT /auth {researcher:true}  ->  GET /api-backend/courses/:id.json" \
  tools="curl,jq" \
  scenario="You have an ordinary student login. Staff-only course views are gated to admin/instructor/researcher, so as a student you get bounced (302) off the research dashboard. But CoLab's account-update endpoint binds attributes straight from the request body - and the list of permitted fields includes 'researcher', a flag the app never meant users to set. is_researcher? simply reads that column." \
  objective="Promote your own account to 'researcher' via the account-update endpoint, then open the staff-only course whose description holds the flag." \
  remediation="Remove 'researcher' (and any role/privilege attribute) from the account_update permitted params; change roles only through an authorized server-side path." \
  hints="First confirm you're blocked: log in as student-bac@colab.test / Password1 and GET http://app:3000/api-backend/courses/4.json - you get HTTP 302 (redirected away). You are not a viewer yet.
The account-update endpoint is PUT /auth (send your auth headers). It trusts whatever JSON fields you send - and one of them controls staff access. Send: {\"researcher\":true}
Re-read GET /api-backend/courses/4.json - now HTTP 200, and the course description carries the flag." \
  provision="bac_provision" toolkit="bac_toolkit" handler=""
