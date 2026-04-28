# buildContainers.ps1
# Builds CoLab containers using Podman on Windows (PowerShell).
# Requires Podman Desktop for Windows: https://podman-desktop.io/
#
# Usage examples:
#   .\buildContainers.ps1 -Both          # Build all containers (default)
#   .\buildContainers.ps1 -DevOnly       # Build db + dev_server + browser + moodle
#   .\buildContainers.ps1 -TestOnly      # Build db + tester
#   .\buildContainers.ps1 -Both -NoCache # Rebuild everything from scratch

[CmdletBinding()]
param(
    [switch]$NoCache,
    [switch]$DevOnly,
    [switch]$TestOnly,
    [switch]$Both,
    [switch]$Help
)

function Show-Help {
    Write-Host "buildContainers.ps1: Script to build Colab containers using Podman"
    Write-Host "Valid options:"
    Write-Host "  -NoCache     Build containers without relying upon the cached layers"
    Write-Host "  -DevOnly     Build dev containers only (db + dev_server + browser + moodle)"
    Write-Host "  -TestOnly    Build test containers only (db + tester)"
    Write-Host "  -Both        Build all containers (default when no selector given)"
    Write-Host "  -Help        Show this help and terminate"
    exit 0
}

function Test-BuildResult {
    param([string]$Name)
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`tbuild ${Name}: succeeded"
    }
    else {
        Write-Host "`n`t*****`n`tbuilding ${Name} failed`n`t*****`n"
        exit 1
    }
}

if ($Help) { Show-Help }

if (-not ($NoCache -or $DevOnly -or $TestOnly -or $Both)) {
    Write-Host "Please specify options"
    Show-Help
}

# --format docker produces Docker-compatible image manifests, required for the
# VS Code Dev Containers extension to start the dev container correctly.
$BuildOpts = @("--format", "docker")
if ($NoCache) {
    Write-Host "Building containers without cache"
    $BuildOpts += "--no-cache"
}

Write-Host "`t*****`n`tbuilding db"
podman build @BuildOpts -f ./containers/agnostic/db/Dockerfile -t colab_db .
Test-BuildResult 'colab_db'

if (-not $DevOnly) {
    Write-Host "`n`t*****`n`tbuilding app tester"
    podman build @BuildOpts -f ./containers/agnostic/tester_server/Dockerfile -t colab_tester .
    Test-BuildResult 'colab_tester'
}

if (-not $TestOnly) {
    Write-Host "`n`t*****`n`tbuilding app dev"
    podman build @BuildOpts -f ./containers/agnostic/dev_server/Dockerfile -t colab_dev_server .
    Test-BuildResult 'colab_dev_server'

    Write-Host "`n`t*****`n`tbuilding browser"
    podman build @BuildOpts -f ./containers/agnostic/browser/Dockerfile -t colab_browser .
    Test-BuildResult 'colab_browser'

    Write-Host "`n`t*****`n`tbuilding moodle"
    podman build @BuildOpts -f ./containers/agnostic/moodle/Dockerfile -t colab_moodle .
    Test-BuildResult 'colab_moodle'
}
