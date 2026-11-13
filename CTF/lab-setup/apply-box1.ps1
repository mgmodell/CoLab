# CoLab CTF - (re)apply Box 1 (IDOR: Student Records) to the running Sec app.
# Box 1 is an EMBEDDED account IDOR in CoLab's real profile page: a student
# changes the student number in the URL (/profile?student=1 -> 3) to view other
# students' accounts (no ownership check). This seeds the target accounts AND
# patches the profile code. Idempotent. Re-run if the app container is recreated.
#   .\apply-box1.ps1
param([string]$Container = "sec_env-app-1")
$ErrorActionPreference = "Stop"
$p   = "C:\Program Files\RedHat\Podman\podman.exe"
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path

& $p cp "$dir\seed_profile_idor.rb"  "${Container}:/tmp/seed_profile_idor.rb"
& $p cp "$dir\patch_profile_idor.rb" "${Container}:/tmp/patch_profile_idor.rb"
Write-Host "  seeding Box 1 accounts (student1..5@idor.local; flag on student3)..." -ForegroundColor Cyan
& $p exec $Container bin/rails runner /tmp/seed_profile_idor.rb
Write-Host "  embedding the account IDOR (home#index + get_profile_hash)..." -ForegroundColor Cyan
& $p exec $Container ruby /tmp/patch_profile_idor.rb
Write-Host "  restarting app (loads the patched controller)..." -ForegroundColor Cyan
& $p restart $Container | Out-Null

Write-Host ""
Write-Host "  Box 1 ready." -ForegroundColor Green
Write-Host "  Play (browser only):" -ForegroundColor DarkGray
Write-Host "    1) log in:  student1@idor.local / Password1"
Write-Host "    2) your profile:  https://localhost:13443/profile?student=1"
Write-Host "    3) change the number 1 -> 3 ; the flag is student 3's account (CoLab{IDOR_RECORDS_2026})"
