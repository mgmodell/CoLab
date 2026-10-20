[CmdletBinding()]
param([switch]$Student)

$ErrorActionPreference = 'SilentlyContinue'
chcp 65001 | Out-Null
try {
  $vt = Add-Type -Name VTlab -Namespace ConHostL -PassThru -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int n);
[DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
[DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);
'@
  $h = $vt::GetStdHandle(-11); $m = 0
  [void]$vt::GetConsoleMode($h, [ref]$m); [void]$vt::SetConsoleMode($h, $m -bor 0x0004)
} catch {}

$img   = 'localhost/colab_pentest:latest'
$mount = 'C:\Users\issia\CoLab\CTF:/opt/ctf'
$name  = 'colab_ctf_lab'
$afile = 'C:\Users\issia\CoLab\CTF\state\active_challenge'
$attackWin = 'C:\Users\issia\CoLab\CTF\._labattack_win.ps1'

podman machine inspect podman-machine-default *> $null
if ($LASTEXITCODE -ne 0) { }
podman info *> $null
if ($LASTEXITCODE -ne 0) { Write-Host "  starting podman machine..." -ForegroundColor DarkGray; podman machine start *> $null }
podman rm -f $name *> $null

function Open-RoomSurfaces {
  Start-Process chrome "http://localhost:8000/"
  Start-Sleep -Milliseconds 800
  Start-Process powershell -ArgumentList '-NoExit','-NoProfile','-ExecutionPolicy','Bypass','-File',$attackWin
}

if ($Student) {
  Write-Host "  CoLab CTF lab - the menu is opening in its own window." -ForegroundColor Cyan
  Write-Host "  Pick a room there; Chrome + your toolkit terminal open automatically." -ForegroundColor DarkGray
  $menuCmd = "podman run --rm -it --name $name -p 8000:8000 --entrypoint bash -e CTF_HOME=/opt/ctf -e CTF_USER=student -e CTF_FORCE_COLOR=1 -e COLORTERM=truecolor -v `"$mount`" -w /opt/ctf $img /opt/ctf/ctf.sh"
  Start-Process powershell -ArgumentList '-NoProfile','-Command',$menuCmd
  $last = ''
  Start-Sleep -Seconds 4
  while ($true) {
    Start-Sleep -Milliseconds 800
    $cur = ''
    try { $cur = (Get-Content $afile -Raw -ErrorAction Stop).Trim() } catch {}
    if ($cur -and $cur -ne $last) { $last = $cur; Open-RoomSurfaces }
    $alive = podman ps --format '{{.Names}}'
    if (-not ($alive -match $name)) { break }
  }
  exit
}

Write-Host ""
Write-Host "  CoLab CTF - LIVE DEMO (room 1: IDOR)" -ForegroundColor Cyan
Write-Host "  Watch: menu -> pick room -> Chrome briefing + toolkit open -> attack -> capture." -ForegroundColor DarkGray
Write-Host ""

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName  = 'podman'
$psi.Arguments = "run --rm -i --name $name -p 8000:8000 --entrypoint bash -e CTF_HOME=/opt/ctf -e CTF_USER=student -e CTF_FORCE_COLOR=1 -e COLORTERM=truecolor -v `"$mount`" -w /opt/ctf $img /opt/ctf/ctf.sh"
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$p = [System.Diagnostics.Process]::Start($psi)

function Send([string]$c, [double]$w) { try { $p.StandardInput.WriteLine($c); $p.StandardInput.Flush() } catch {}; Start-Sleep -Seconds $w }

Start-Sleep -Seconds 8
Send '1' 8                       # open room 1 -> loading bar -> READY -> briefing
Write-Host "`n  >> room selected: opening Chrome briefing + toolkit terminal..." -ForegroundColor Cyan
Open-RoomSurfaces
Start-Sleep -Seconds 18          # the toolkit window performs the live IDOR attack
Write-Host "`n  >> submitting the recovered flag in the menu..." -ForegroundColor Cyan
Send 's' 2.5
Send 'CoLab{idor_grade_ledger_cd022499}' 4
Send 'n' 3
Send 'b' 2
Write-Host ""
Write-Host "  DEMO COMPLETE - room 1 captured. Menu, Chrome briefing, and toolkit are all live." -ForegroundColor Green
Read-Host "  Press Enter to close the lab"
Send 'q' 1
try { $p.StandardInput.Close() } catch {}
$p.WaitForExit()
