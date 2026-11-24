# CoLab CTF - (re)apply the EMBEDDED rooms (boxes 3-11) to the running Sec app.
# Each room's vulnerability is embedded INTO real CoLab (a controller/route/seed),
# never a fake page. Idempotent. Re-run if the app container is recreated (patches
# live only in sec_env-app-1's writable layer).  Box 1 has its own apply-box1.ps1.
#   .\apply-embeds.ps1
param([string]$Container = "sec_env-app-1")
$ErrorActionPreference = "Stop"
$p   = "C:\Program Files\RedHat\Podman\podman.exe"
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path

# seeds: bin/rails runner (DB inserts);  patches: ruby (edit code/routes in place)
$seeds   = @("seed_bac.rb","seed_xss.rb","seed_sqli.rb")
$patches = @("patch_ssrf.rb","patch_verbose.rb","patch_xss.rb","patch_csrf.rb",
             "patch_sqli.rb","patch_cmdinj.rb","patch_deser_unsigned.rb","patch_jwt.rb")

foreach ($f in $seeds + $patches) {
  $src = Join-Path $dir $f
  if (Test-Path $src) { & $p cp $src "${Container}:/tmp/$f" }
}
foreach ($f in $seeds) {
  if (Test-Path (Join-Path $dir $f)) {
    Write-Host "  seeding: $f" -ForegroundColor Cyan
    & $p exec $Container bin/rails runner "/tmp/$f"
  }
}
foreach ($f in $patches) {
  if (Test-Path (Join-Path $dir $f)) {
    Write-Host "  patching: $f" -ForegroundColor Cyan
    & $p exec $Container ruby "/tmp/$f"
  }
}
Write-Host "  restarting app (loads patched controllers/routes)..." -ForegroundColor Cyan
& $p restart $Container | Out-Null
Write-Host "  embedded rooms applied." -ForegroundColor Green
