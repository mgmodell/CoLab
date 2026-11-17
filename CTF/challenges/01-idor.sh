#!/usr/bin/env bash
# =============================================================================
#  Easy - IDOR: Student Records   (REAL CoLab app, browser-only, box 1)
#  You're signed in to CoLab as a student, looking at your OWN profile. The URL
#  carries your student number:  /profile?student=1 . CoLab trusts that number
#  and never checks it's really you - so changing it to 2, 3, 4 ... opens OTHER
#  students' account pages. Student 3's account holds the flag. Classic account
#  IDOR, done entirely in the browser address bar.
#
#  TRAINING PLATFORM: the vulnerability is deliberately EMBEDDED into CoLab's own
#  profile page (home#index + get_profile_hash, modified in place - see
#  CTF/lab-setup/patch_profile_idor.rb). It renders on CoLab's real SPA profile
#  screen; the flag is a real seeded account (CTF/lab-setup/seed_profile_idor.rb).
#  No fabricated page, no new route.
# =============================================================================

idor2_provision() { return 0; }   # target seeded + patched out-of-band (lab-setup/apply-box1.ps1)

idor2_handle() {
  mw_resp "200 OK" '{"note":"Box 1 is the REAL CoLab app, in the browser. Type !hint for the steps."}' \
    "Content-Type: application/json"
}

register_challenge \
  id="easy-idor-url" \
  title="IDOR: Student Records - Easy" \
  diff="Easy" points="100" penalty="15" \
  owasp="A01:2021 Broken Access Control (IDOR)" \
  cvss="6.5 (AV:N/AC:L/PR:L/S:U/C:H)" \
  slug="idor_student_records" \
  finding="CoLab Pentest Report - profile shown by the student number in the URL with no ownership check" \
  endpoint="GET /profile?student=:n  (home#index -> get_profile_hash)" \
  tools="browser" \
  scenario="You're signed in to CoLab as a student, looking at your OWN profile. The URL carries your student number - /profile?student=1 - and CoLab trusts it, never checking that account is really yours. So by changing that number you can open OTHER students' account pages. One of them holds the flag." \
  objective="In the browser, change the student number in the URL to open an account that isn't yours, and read the flag off that student's profile." \
  remediation="Never load an account from an id in the URL for a non-privileged user; always scope the profile to the authenticated session (current_user) and authorize any cross-account view." \
  browse="https://localhost:13443/" \
  live="https://localhost:13443/" \
  hints="Log in to CoLab with the student account:  student1@idor.local  /  Password1
Open your own profile:  https://localhost:13443/profile?student=1  - that '1' on the end of the URL is your student number.
Change that number in the address bar to other students (2, 3, 4 ...) and press Enter. CoLab never checks the account is yours - that's the IDOR. The flag is student 3's account:  https://localhost:13443/profile?student=3  (it's in the First name / 'Tell us about yourself' field)." \
  provision="idor2_provision" handler="idor2_handle"
