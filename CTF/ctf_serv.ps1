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
    $mount = "${ScriptDir}:/opt/ctf"
    & podman run --rm -it `
        --name $Container `
        --network $Net `
        --hostname colab-ctf `
        -e COLORTERM=truecolor -e TERM=xterm-256color `
        --entrypoint /bin/bash `
        -v $mount `
        -w /opt/ctf `
        $Image @Cmd
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
} else {
    Write-Host "  CoLab CTF - booting in Podman ($Image)" -ForegroundColor Cyan
    Write-Host "  isolated internal net '$Net' - CTF at /opt/ctf - full Sec toolkit - progress saved on host" -ForegroundColor DarkGray
    Invoke-Toolbox @('/opt/ctf/ctf.sh')
    Write-Host "  CTF container stopped - your progress is saved." -ForegroundColor DarkGray
}
