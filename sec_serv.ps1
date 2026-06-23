# sec_serv.ps1
# Start, stop, and interact with the CoLab security (pentest) environment on
# Windows using Podman (PowerShell). This is the host-side twin of sec_serv.sh -
# run it from a HOST shell (Windows Terminal / PowerShell), NOT from inside the
# VS Code dev container (that container has no podman).
#
# Requires Podman Desktop for Windows: https://podman-desktop.io/
#
# Usage examples:
#   .\sec_serv.ps1 -Up          # bring the environment up (waits until ready)
#   .\sec_serv.ps1 -Status      # show container status
#   .\sec_serv.ps1 -Pentest     # open a shell in the Kali toolbox
#   .\sec_serv.ps1 -Init        # (re-)initialise the DB from db/dev_db.sql
#   .\sec_serv.ps1 -Down        # tear the environment down (keep volumes)
#   .\sec_serv.ps1 -Help        # full help

[CmdletBinding()]
param(
    [switch]$Up,
    [switch]$Build,
    [switch]$Stop,
    [switch]$Restart,
    [switch]$Down,
    [switch]$DownVolumes,
    [switch]$Status,
    [switch]$Logs,
    [switch]$Pentest,
    [switch]$Console,
    [switch]$Mysql,
    [switch]$Init,
    [switch]$Seed,
    [switch]$Win,
    [switch]$Help
)

function Show-Help {
    Write-Host "sec_serv.ps1: Interact with the CoLab security (pentest) environment"
    Write-Host "Valid options:"
    Write-Host "  -Up           Pick engagement mode (Black/White/Gray box), then bring the"
    Write-Host "                environment up (build if needed); waits until ready"
    Write-Host "  -Build        Build/(re)build all images"
    Write-Host "  -Stop         Stop containers, keep volumes"
    Write-Host "  -Restart      Restart the environment"
    Write-Host "  -Down         Tear the environment down (remove containers/networks)"
    Write-Host "  -DownVolumes  Tear down AND remove volumes (destroys the sandbox DB)"
    Write-Host "  -Status       Show container status"
    Write-Host "  -Logs         Tail logs (follow) for the whole stack"
    Write-Host "  -Pentest      Open a shell in the Kali toolbox (main interaction)"
    Write-Host "  -Console      Open a production rails console on the target"
    Write-Host "  -Mysql        Open a mysql session on the target DB (colab_prod)"
    Write-Host "  -Init         (re-)Initialise the target DB from db/dev_db.sql, then migrate"
    Write-Host "  -Seed         Seed the target: rails db:seed + sandbox test users"
    Write-Host "  -Win          Add the Windows compose override (Podman Desktop)"
    Write-Host "  -Help         Show this help and terminate"
    exit 0
}

if ($Help -or -not ($Up -or $Build -or $Stop -or $Restart -or $Down -or $DownVolumes `
        -or $Status -or $Logs -or $Pentest -or $Console -or $Mysql -or $Init -or $Seed)) {
    Show-Help
}

# Require Podman on PATH.
if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Write-Error "'podman' was not found on PATH. Install Podman Desktop (https://podman-desktop.io/) and retry."
    Write-Host  "Note: run this from a HOST PowerShell/Windows Terminal, not the VS Code dev-container terminal."
    exit 1
}

# Resolve paths from this script's own location.
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ComposeFile = Join-Path $ScriptDir 'containers\sec_env\docker-compose.yml'
$WinFile     = Join-Path $ScriptDir 'containers\sec_env\docker-compose.windows.yml'
$Snapshot    = Join-Path $ScriptDir 'db\dev_db.sql'
$BootMode    = Join-Path $ScriptDir 'boot_mode.sh'
$ModeEnv     = Join-Path $ScriptDir 'containers\sec_env\.env'

# Load the selected engagement mode (PENTEST_MODE/TESTER/SESSION) into this
# process so every `compose` call passes it into the toolbox container. The
# selector (below) writes containers/sec_env/.env; here we just pick up whatever
# the last selection was (if any). Mirrors `load_mode_env` in sec_serv.sh.
function Import-ModeEnv {
    if (Test-Path $ModeEnv) {
        foreach ($line in Get-Content -LiteralPath $ModeEnv) {
            if ($line -match '^\s*#') { continue }
            if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$') {
                $val = $Matches[2].Trim('"').Trim("'")
                Set-Item -Path "env:$($Matches[1])" -Value $val
            }
        }
    }
}

# Locate Git Bash to run the (shared) boot_mode.sh selector. We deliberately
# prefer Git Bash and AVOID the WindowsApps 'bash.exe' WSL stub: it can't run a
# Windows-path script and may not be configured.
function Find-Bash {
    $candidates = @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "$env:ProgramFiles\Git\usr\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )
    $px86 = [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
    if ($px86) { $candidates += (Join-Path $px86 'Git\bin\bash.exe') }
    foreach ($p in $candidates) { if (Test-Path $p) { return $p } }
    $cmd = Get-Command bash -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source -notmatch 'WindowsApps') { return $cmd.Source }
    return $null
}

# Native PowerShell fallback selector (used only when no bash is available).
# Writes the same containers/sec_env/.env so the mode still reaches the toolbox.
# It does NOT generate the session record / Quick Start - that needs boot_mode.sh.
function Select-ModeNative {
    Write-Host ""
    Write-Host "  Select Pentest Mode:" -ForegroundColor Cyan
    Write-Host "    [1] Black Box  - No prior knowledge. Simulate an external attacker."
    Write-Host "    [2] White Box  - Full access to source, stack, and credentials."
    Write-Host "    [3] Gray Box   - Partial knowledge (role-based access, partial docs)."
    do { $choice = Read-Host "  Mode [1-3]" } until ($choice -in '1', '2', '3')
    $mode = @{ '1' = 'blackbox'; '2' = 'whitebox'; '3' = 'graybox' }[$choice]
    $tester = Read-Host "  Tester name (for the audit trail)"
    if ([string]::IsNullOrWhiteSpace($tester)) { $tester = 'unnamed-operator' }
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $envDir = Split-Path -Parent $ModeEnv
    if (-not (Test-Path $envDir)) { New-Item -ItemType Directory -Force -Path $envDir | Out-Null }
    @(
        '# Generated by sec_serv.ps1 native mode selector.',
        "PENTEST_MODE=`"$mode`"",
        "PENTEST_TESTER=`"$tester`"",
        "PENTEST_SESSION=`"$stamp`""
    ) | Set-Content -Encoding ascii -LiteralPath $ModeEnv
    $env:PENTEST_MODE = $mode; $env:PENTEST_TESTER = $tester; $env:PENTEST_SESSION = $stamp
    Write-Host ""
    Write-Host "  ENGAGEMENT MODE: $($mode.ToUpper())" -ForegroundColor Green
    Write-Host "  PENTEST_MODE=$mode  (echo `$PENTEST_MODE inside the toolbox)"
    Write-Host "  (Install Git Bash to also auto-generate the session record + Quick Start.)" -ForegroundColor DarkGray
    Write-Host ""
}

# Engagement kickoff: run the interactive mode selector before the stack comes
# up. Prefer the shared boot_mode.sh (full briefing + session log + Quick Start)
# via Git Bash; fall back to the native PowerShell prompt otherwise.
function Invoke-ModeSelector {
    if (Test-Path $BootMode) {
        $bash = Find-Bash
        if ($bash) {
            & $bash $BootMode
            Import-ModeEnv   # reload the freshly selected mode
            return
        }
        Write-Host "NOTE: Git Bash not found - using the built-in PowerShell mode prompt." -ForegroundColor Yellow
    }
    Select-ModeNative
}

# Pick up any previously-selected mode for non-Up commands (-Pentest, etc.).
Import-ModeEnv

# Assemble the compose argument list (optionally with the Windows override).
$Compose = @('compose', '-f', $ComposeFile)
if ($Win) { $Compose += @('-f', $WinFile) }

# NOTE: use the automatic $args (NOT a declared [ValueFromRemainingArguments]
# parameter). The declared form silently DROPS dash-flags like -d/-v/-f (PowerShell
# tries to bind them as parameter names), which made `up -d` attach instead of
# detach and hang. The automatic $args passes every token through verbatim.
function Invoke-Compose { & podman @Compose @args }

# The Podman engine must be reachable. The #1 post-reboot gotcha is a stopped
# Podman machine, which makes every command fail cryptically.
function Test-PodmanUp {
    podman info *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Cannot reach the Podman engine."
        Write-Host  "On Windows the Podman machine is often stopped after a reboot. Start it, then re-run:"
        Write-Host  "    podman machine start"
        exit 1
    }
}

# Ensure the stack is running before exec'ing into a container. It can stop after
# the host sleeps/reboots (Podman's restart policy doesn't always survive a
# machine restart), making `exec` fail with "container is not running". No-op
# when the toolbox is already up.
function Ensure-Up {
    $cid = (& podman @Compose ps -q pentest 2>$null | Select-Object -First 1)
    $running = $false
    if ($cid) { $running = ((& podman inspect -f '{{.State.Running}}' $cid 2>$null) -eq 'true') }
    if (-not $running) {
        Write-Host "Environment isn't running - starting it (this also waits for the DB)..."
        Invoke-Compose up -d
    }
}

# Poll the target health endpoint until it serves (first boot runs migrations).
function Wait-Target {
    param([int]$Tries = 90)
    Write-Host "Waiting for the CoLab target to become ready"
    Write-Host "  (first boot waits for the DB and runs migrations - this can take a minute)..."
    for ($i = 0; $i -lt $Tries; $i++) {
        try {
            $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 -Uri 'http://localhost:13000/up' -ErrorAction Stop
            if ($r.StatusCode -eq 200) { return $true }
        } catch { }
        Start-Sleep -Seconds 2
    }
    return $false
}

Test-PodmanUp

if ($Build) {
    Write-Host "Building the security environment images..."
    Invoke-Compose build
}

if ($Up) {
    # Engagement kickoff: choose Black/White/Gray box BEFORE the containers spin
    # up. Writes containers/sec_env/.env so PENTEST_MODE reaches the toolbox.
    # Re-running -Up re-prompts (idempotent).
    Invoke-ModeSelector
    Write-Host "Starting the security environment (detached)..."
    Invoke-Compose up -d
    Write-Host ""
    if (Wait-Target 90) {
        Write-Host "  Target is UP" -ForegroundColor Green
        Write-Host "     Browser / login : https://localhost:13443  (HTTPS - accept the self-signed cert)" -ForegroundColor Green
        Write-Host "     Direct HTTP     : http://localhost:13000   (recon/tools; login needs the HTTPS URL)"
        Write-Host "     In-network      : http://app:3000"
    } else {
        Write-Host "  Target is not answering yet on http://localhost:13000." -ForegroundColor Yellow
        Write-Host "  The DB's first-time init can be slow; wait a minute, then reload the URL."
        Write-Host "  Inspect with:  .\sec_serv.ps1 -Logs    (or  .\sec_serv.ps1 -Status )"
    }
    Write-Host "  Pentest toolbox     : .\sec_serv.ps1 -Pentest"
    Write-Host "  (Re-)initialise DB  : .\sec_serv.ps1 -Init   |   Seed data: .\sec_serv.ps1 -Seed"
}

if ($Restart) {
    Write-Host "Restarting the security environment..."
    Invoke-Compose restart
}

if ($Init) {
    Write-Host "Initialising the target database (colab_prod)..."
    if ((Test-Path $Snapshot) -and ((Get-Item $Snapshot).Length -gt 0)) {
        Write-Host "Loading snapshot: $Snapshot"
        Get-Content -Raw $Snapshot | & podman @Compose exec -T db mariadb colab_prod -uprod -pprod
        Write-Host "Snapshot loaded."
    } else {
        Write-Host "NOTE: $Snapshot is empty or missing - skipping snapshot load."
        Write-Host "      The schema will be created from production migrations instead."
    }
    Write-Host "Running production migrations on the target..."
    & podman @Compose exec -T app sh -lc 'cd /app && exec bin/colab_prod_entrypoint.sh migrate'
    Write-Host "Database initialised."
}

if ($Seed) {
    Write-Host "Seeding the production target - foundational data (rails db:seed)..."
    & podman @Compose exec -T app sh -lc 'cd /app && RAILS_ENV=production mise exec -- bundle exec rails db:seed'
    Write-Host "Seeding sandbox test users (db/seed_pentest_users.rb)..."
    & podman @Compose exec -T app sh -lc 'cd /app && RAILS_ENV=production mise exec -- bundle exec rails runner db/seed_pentest_users.rb'
    Write-Host "Seeding complete. Sandbox accounts can log in at https://localhost:13443."
}

if ($Pentest) {
    Ensure-Up
    Write-Host "Opening a shell in the pentest toolbox..."
    Invoke-Compose exec pentest bash -l
}

if ($Console) {
    Ensure-Up
    Write-Host "Opening a production rails console on the target..."
    & podman @Compose exec app sh -lc 'cd /app && exec bin/colab_prod_entrypoint.sh console'
}

if ($Mysql) {
    Ensure-Up
    Write-Host "Opening a mysql session on colab_prod..."
    Invoke-Compose exec db mariadb colab_prod -uprod -pprod
}

if ($Status) { Invoke-Compose ps }

if ($Logs) { Invoke-Compose logs -f }

if ($Stop) {
    Write-Host "Stopping the security environment..."
    Invoke-Compose stop
}

if ($Down -or $DownVolumes) {
    if ($DownVolumes) {
        Write-Host "Tearing down the security environment AND removing volumes..."
        Invoke-Compose down -v
    } else {
        Write-Host "Tearing down the security environment..."
        Invoke-Compose down
    }
}
