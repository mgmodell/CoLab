# ============================================================================
# ctf_serv.ps1 — CoLab CTF launcher (Windows PowerShell / Podman Desktop).
#
# Boots the CoLab CTF training range IN PODMAN, inside the same Kali toolbox
# image the engagement uses (colab_pentest), so students get the full toolkit
# next to the challenges. Isolated internal network; CTF bind-mounted writable
# at /opt/ctf; progress saved on the host.
#
# COMPLETELY SEPARATE from the Sec engagement boot (never touches boot_mode.sh,
# .env, or the app/db/proxy stack).
#
# Usage (from a HOST PowerShell — NOT the VS Code dev-container terminal):
#   .\ctf_serv.ps1            Boot the CTF in podman and play   (default)
#   .\ctf_serv.ps1 -Shell     Open the Kali toolbox shell (CTF at /opt/ctf)
#   .\ctf_serv.ps1 -Status    Show engine/image status
#   .\ctf_serv.ps1 -Build     Build the toolbox image (one-time, reuses Sec Dockerfile)
#   .\ctf_serv.ps1 -Down      Remove the CTF container + internal network
#   .\ctf_serv.ps1 -OnHost    Run on the bare host via Git Bash (fallback)
#   .\ctf_serv.ps1 -Help      This help
# ============================================================================
[CmdletBinding()]
param(
    [switch]$Shell,
    [switch]$Status,
    [switch]$Build,
    [switch]$Down,
    [switch]$OnHost,
    [switch]$Help
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir
$Image     = 'colab_pentest:latest'
$Container = 'colab_ctf_toolbox'
$Net       = 'colab_ctf_net'

function Show-Help { Get-Content $MyInvocation.MyCommand.Path | Select-Object -Skip 1 -First 25 | ForEach-Object { $_ -replace '^#\s?','' } }

if ($Help) { Show-Help; return }

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Write-Error "'podman' was not found on PATH. Install Podman Desktop (https://podman-desktop.io/) and retry."
    return
}

function Test-Engine {
    podman info *> $null
    if ($LASTEXITCODE -eq 0) { return $true }
    $machines = (podman machine list --format '{{.Name}}' 2>$null)
    if ($machines) {
        Write-Host "  Podman engine not ready - starting the podman machine (one moment)..." -ForegroundColor DarkGray
        podman machine start *> $null
    }
    podman info *> $null
    if ($LASTEXITCODE -eq 0) { return $true }
    Write-Host "  Cannot reach the Podman engine. Start it and re-run:" -ForegroundColor Red
    Write-Host "      podman machine start"
    return $false
}

function Test-Image {
    podman image exists $Image 2>$null
    if ($LASTEXITCODE -eq 0) { return $true }
    Write-Host "  Toolbox image '$Image' isn't built yet (one-time, ~8 GB)." -ForegroundColor Red
    Write-Host "  Build it:   .\ctf_serv.ps1 -Build   (or reuse the Sec lab:  .\sec_serv.ps1 -Build )"
    return $false
}

function Ensure-Net {
    podman network exists $Net *> $null
    if ($LASTEXITCODE -ne 0) { podman network create --internal $Net *> $null }
}

function Invoke-Toolbox {
    param([string[]]$Cmd)
    Ensure-Net
    # Also join the Sec engagement network (if the real CoLab stack is up) so
    # real-app rooms can attack the live target as app:3000.
    $extraNet = @()
    podman network exists 'sec_env_engagement_net' *> $null
    if ($LASTEXITCODE -eq 0) { $extraNet = @('--network', 'sec_env_engagement_net') }
    else { Write-Host "  (real-app rooms need the CoLab stack: .\sec_serv.ps1 -u)" -ForegroundColor DarkYellow }
    $mount = "${ScriptDir}:/opt/ctf"
    & podman run --rm -it `
        --name $Container `
        --network $Net @extraNet `
        --hostname colab-ctf `
        -e COLORTERM=truecolor -e TERM=xterm-256color `
        -e "CTF_USER=$env:CTF_USER" `
        -e CTF_TARGET_REAL=http://app:3000 `
        --entrypoint /bin/bash `
        -v $mount `
        -w /opt/ctf `
        $Image @Cmd
}

# Resolve Chrome's full path (chrome is usually NOT on PATH, so a bare-name
# launch silently no-ops). The host opens Chrome directly between picking a room
# and entering it — no background job.
function Resolve-Chrome {
    foreach ($c in @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
                     "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                     "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe")) {
        if (Test-Path $c) { return $c }
    }
    return 'chrome'   # last resort: hope it's on PATH
}

if ($Status) {
    Write-Host "  CoLab CTF - status" -ForegroundColor Cyan
    podman info *> $null
    if ($LASTEXITCODE -eq 0) { Write-Host "    engine : podman ready" -ForegroundColor Green }
    else { Write-Host "    engine : not ready (run: podman machine start)" -ForegroundColor Red }
    podman image exists $Image 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "    image  : $Image present" -ForegroundColor Green }
    else { Write-Host "    image  : $Image missing (run: .\ctf_serv.ps1 -Build)" -ForegroundColor Red }
    return
}

if ($Down) {
    podman rm -f $Container *> $null
    podman network rm $Net  *> $null
    Write-Host "  CTF container + network removed." -ForegroundColor Green
    return
}

if ($Build) {
    if (-not (Test-Engine)) { return }
    Write-Host "  building $Image from the Sec pentest Dockerfile (large, one-time)..."
    Push-Location $RepoRoot
    podman build -t $Image -f containers/agnostic/pentest/Dockerfile .
    Pop-Location
    return
}

if ($OnHost) {
    $bash = (Get-Command bash -ErrorAction SilentlyContinue)
    if (-not $bash) { Write-Error "Git Bash 'bash' not found for host mode. Use podman mode instead."; return }
    Write-Host "  Running the CTF on the bare host via Git Bash (not podman)." -ForegroundColor Yellow
    & bash "$ScriptDir/ctf.sh"
    return
}

# Default / -Shell : boot in podman
if (-not (Test-Engine)) { return }
if (-not (Test-Image))  { return }

if ($Shell) {
    Write-Host "  Kali toolbox shell - CTF is at /opt/ctf (run ./ctf.sh)" -ForegroundColor Cyan
    Write-Host "  tools: curl sqlmap jwt_tool ffuf gitleaks nuclei nmap python3 jq ..." -ForegroundColor DarkGray
    Invoke-Toolbox @('-l')
    return
}

# Default: one Kali container stays up; the menu runs inside it as two phases
# (__pick then __room) via `podman exec -it`, so the HOST regains control between
# them and opens Chrome directly when you start a room - no background job.
Ensure-Net
$extraNet = @()
podman network exists 'sec_env_engagement_net' *> $null
if ($LASTEXITCODE -eq 0) { $extraNet = @('--network', 'sec_env_engagement_net') }
else { Write-Host "  (real-app rooms need the CoLab stack up: .\sec_serv.ps1 -u)" -ForegroundColor DarkYellow }
$mount     = "${ScriptDir}:/opt/ctf"
$chromeExe = Resolve-Chrome
$selRoom = Join-Path $ScriptDir 'state\selected_room'
$selUrl  = Join-Path $ScriptDir 'state\selected_url'
$ctl     = Join-Path $ScriptDir 'state\ctl'

podman rm -f $Container *> $null
& podman run -d --name $Container `
    --network $Net @extraNet `
    --hostname colab-ctf `
    -e COLORTERM=truecolor -e TERM=xterm-256color `
    -e "CTF_USER=$env:CTF_USER" `
    -e CTF_TARGET_REAL=http://app:3000 `
    -v $mount -w /opt/ctf `
    --entrypoint sleep $Image infinity *> $null

Write-Host "  CoLab CTF - pick a vulnerability; Chrome opens the live CoLab when you start a room." -ForegroundColor Cyan
try {
    while ($true) {
        Remove-Item $selRoom, $selUrl, $ctl -Force -ErrorAction SilentlyContinue
        & podman exec -it $Container /opt/ctf/ctf.sh __pick
        if ((Test-Path $ctl) -and (((Get-Content $ctl -Raw) -replace '\s','') -eq 'quit')) { break }
        if (-not (Test-Path $selRoom)) { continue }
        $room = (Get-Content $selRoom -Raw).Trim()
        if (Test-Path $selUrl) {
            $u = (Get-Content $selUrl -Raw).Trim()
            if ($u) { Start-Process $chromeExe -ArgumentList '--new-window', $u }
        }
        & podman exec -it $Container /opt/ctf/ctf.sh __room $room
    }
} finally {
    podman rm -f $Container *> $null
    Write-Host "  CTF stopped - progress saved." -ForegroundColor DarkGray
}
