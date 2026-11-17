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

podman info *> $null
if ($LASTEXITCODE -ne 0) { Write-Host "  starting podman machine..." -ForegroundColor DarkGray; podman machine start *> $null }
# Free port 8000 / clear any prior lab container so this one can bind it.
$stale = podman ps -q --filter ancestor=localhost/colab_pentest:latest
if ($stale) { podman kill $stale *> $null }
podman rm -f $name colab_ctf_web *> $null

function Open-RoomSurfaces {
  Start-Process chrome "http://localhost:8000/lab"    # the task briefing (what to do)
  Start-Sleep -Milliseconds 900
  Start-Process chrome "http://localhost:8000/"       # the CoLab site (your own grades)
  Start-Sleep -Milliseconds 900
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

# Console.InputEncoding drives the child's stdin StreamWriter; a UTF-8-with-BOM
# encoding would prepend a BOM that the TUI reads as part of the first input.
try { [Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false } catch {}

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName  = 'podman'
$psi.Arguments = "run --rm -i --name $name -p 8000:8000 --entrypoint bash -e CTF_HOME=/opt/ctf -e CTF_USER=student -e CTF_FORCE_COLOR=1 -e COLORTERM=truecolor -v `"$mount`" -w /opt/ctf $img /opt/ctf/ctf.sh"
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$p = [System.Diagnostics.Process]::Start($psi)
$p.StandardInput.NewLine = "`n"   # LF only (TUI also strips any stray CR)

function Send([string]$c, [double]$w) {
  try { $p.StandardInput.WriteLine($c); $p.StandardInput.Flush() } catch {}
  Start-Sleep -Seconds $w
}

Start-Sleep -Seconds 10
Write-Host "`n  ===== STEP 1: picking room 1 (IDOR) from the menu =====" -ForegroundColor Yellow
Start-Sleep -Seconds 3
Send '1' 2
for ($i = 0; $i -lt 25; $i++) {
  $a = ''
  try { $a = (Get-Content $afile -Raw -ErrorAction Stop).Trim() } catch {}
  if ($a -eq 'easy-idor') { break }
  Start-Sleep -Milliseconds 700
}
Start-Sleep -Seconds 5            # let the boot bar / READY / briefing be read in this window
Write-Host "`n  ===== STEP 2: the room is live =====" -ForegroundColor Yellow
Write-Host "  >>> LOOK AT GOOGLE CHROME: tab 1 = the task, tab 2 = the CoLab grades site (your record)." -ForegroundColor Cyan
Open-RoomSurfaces
Start-Sleep -Seconds 14           # pause so the CoLab site + briefing can be read
Write-Host "`n  ===== STEP 3: the attack (toolkit) =====" -ForegroundColor Yellow
Write-Host "  >>> LOOK AT THE TOOLKIT WINDOW: it runs the IDOR attack with curl." -ForegroundColor Cyan
Start-Sleep -Seconds 30           # the toolkit window performs the paced live attack
Write-Host "`n  ===== STEP 3b: the SAME IDOR, in the browser, on the CoLab site =====" -ForegroundColor Yellow
Write-Host "  >>> LOOK AT CHROME: changing the id to 1337 shows another student's CONFIDENTIAL record + flag." -ForegroundColor Cyan
Start-Process chrome "http://localhost:8000/?id=1337"
Start-Sleep -Seconds 12
Write-Host "`n  ===== STEP 4: submitting the recovered flag here in the menu =====" -ForegroundColor Yellow
Start-Sleep -Seconds 2
Send 's' 3
Send 'CoLab{idor_grade_ledger_cd022499}' 5
Send 'n' 4
Write-Host ""
Write-Host "  ===== DEMO COMPLETE - room 1 captured (+100). All three windows stay live. =====" -ForegroundColor Green
Read-Host "  Press Enter to close the lab"
Send 'b' 1
Send 'q' 1
try { $p.StandardInput.Close() } catch {}
$p.WaitForExit()
