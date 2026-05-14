# configureDevcontainer.ps1
# Detects Podman rootless mode and host OS, then updates
# .devcontainer/devcontainer.json dockerComposeFile accordingly.

$ErrorActionPreference = "Stop"

$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$devcontainerFile = Join-Path $rootDir ".devcontainer/devcontainer.json"

$baseCompose = "../containers/dev_env/docker-compose.yml"
$linuxRootlessCompose = "../containers/dev_env/docker-compose.rootless.yml"
$macosRootlessCompose = "../containers/dev_env/docker-compose.macos.yml"

if (-not (Test-Path $devcontainerFile)) {
    throw "Missing file: $devcontainerFile"
}

$isLinux = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)
$isMacOS = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)

$rootless = "false"
$podmanCmd = Get-Command podman -ErrorAction SilentlyContinue
if ($null -ne $podmanCmd) {
    try {
        $rootless = (podman info --format '{{.Host.Security.Rootless}}').Trim().ToLowerInvariant()
    }
    catch {
        $rootless = "false"
    }
}

$composeJson = '"' + $baseCompose + '"'
$selectionNote = "base compose file"

if ($rootless -eq "true" -and $isLinux) {
    $composeJson = '["' + $baseCompose + '", "' + $linuxRootlessCompose + '"]'
    $selectionNote = "Linux rootless override"
}
elseif ($rootless -eq "true" -and $isMacOS) {
    $composeJson = '["' + $baseCompose + '", "' + $macosRootlessCompose + '"]'
    $selectionNote = "macOS rootless override"
}

$content = Get-Content -Raw -Path $devcontainerFile
$pattern = '"dockerComposeFile"\s*:\s*(\[[\s\S]*?\]|"[^"]*")\s*,'
$replacement = '"dockerComposeFile": ' + $composeJson + ','
$updated = [System.Text.RegularExpressions.Regex]::Replace(
    $content,
    $pattern,
    $replacement,
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)

if ($updated -eq $content) {
    throw "Could not locate dockerComposeFile in .devcontainer/devcontainer.json"
}

Set-Content -Path $devcontainerFile -Value $updated -NoNewline
Write-Host "Updated .devcontainer/devcontainer.json dockerComposeFile ($selectionNote)."
