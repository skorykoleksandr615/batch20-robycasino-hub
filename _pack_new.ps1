$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$src = Join-Path $env:USERPROFILE ".cursor\projects\c-AndroidStudioProjects-batch20-hubs\assets"
$dst = "C:\AndroidStudioProjects\batch20-hubs\robycasino"
$hub = Join-Path $dst "assets"

function Save-Jpeg($srcPath, $dstPath, $quality, $maxW) {
  $im = [System.Drawing.Image]::FromFile($srcPath)
  $clone = $im
  $disposeClone = $false
  if ($im.Width -gt $maxW) {
    $nh = [int]($im.Height * $maxW / $im.Width)
    $clone = New-Object System.Drawing.Bitmap $maxW, $nh
    $g = [System.Drawing.Graphics]::FromImage($clone)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($im, 0, 0, $maxW, $nh)
    $g.Dispose()
    $disposeClone = $true
  }
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
  $dir = Split-Path $dstPath -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $clone.Save($dstPath, $codec, $ep)
  if ($disposeClone) { $clone.Dispose() }
  $im.Dispose()
  Write-Host ("packed {0} -> {1} ({2})" -f (Split-Path $srcPath -Leaf), $dstPath.Substring($dst.Length+1), (Get-Item $dstPath).Length)
}

# Remap existing hub files that already match titles
Copy-Item (Join-Path $hub "slots\slots-02.jpg") (Join-Path $hub "slots\_mental.jpg") -Force
Copy-Item (Join-Path $hub "slots\slots-03.jpg") (Join-Path $hub "slots\_tombstone.jpg") -Force
Copy-Item (Join-Path $hub "slots\slots-07.jpg") (Join-Path $hub "slots\_bandit.jpg") -Force
Copy-Item (Join-Path $hub "slots\slots-08.jpg") (Join-Path $hub "slots\_duel.jpg") -Force
Copy-Item (Join-Path $hub "slots\slots-09.jpg") (Join-Path $hub "slots\_fire.jpg") -Force
Copy-Item (Join-Path $hub "crash\crash-03.jpg") (Join-Path $hub "crash\_jetx.jpg") -Force
Copy-Item (Join-Path $hub "crash\crash-06.jpg") (Join-Path $hub "crash\_aviatrix.jpg") -Force
Copy-Item (Join-Path $hub "live\live-02.jpg") (Join-Path $hub "live\_bj.jpg") -Force
Copy-Item (Join-Path $hub "live\live-04.jpg") (Join-Path $hub "live\_lightning_old.jpg") -Force

Copy-Item (Join-Path $hub "slots\_mental.jpg") (Join-Path $hub "slots\slots-04.jpg") -Force
Copy-Item (Join-Path $hub "slots\_duel.jpg") (Join-Path $hub "slots\slots-05.jpg") -Force
Copy-Item (Join-Path $hub "slots\_bandit.jpg") (Join-Path $hub "slots\slots-06.jpg") -Force
Copy-Item (Join-Path $hub "slots\_tombstone.jpg") (Join-Path $hub "slots\slots-07.jpg") -Force
Copy-Item (Join-Path $hub "slots\_fire.jpg") (Join-Path $hub "slots\slots-08.jpg") -Force
Copy-Item (Join-Path $hub "crash\_jetx.jpg") (Join-Path $hub "crash\crash-04.jpg") -Force
Copy-Item (Join-Path $hub "crash\_aviatrix.jpg") (Join-Path $hub "crash\crash-05.jpg") -Force
Copy-Item (Join-Path $hub "live\_bj.jpg") (Join-Path $hub "live\live-04.jpg") -Force

Remove-Item (Join-Path $hub "slots\_mental.jpg"), (Join-Path $hub "slots\_tombstone.jpg"), (Join-Path $hub "slots\_bandit.jpg"), (Join-Path $hub "slots\_duel.jpg"), (Join-Path $hub "slots\_fire.jpg") -Force
Remove-Item (Join-Path $hub "crash\_jetx.jpg"), (Join-Path $hub "crash\_aviatrix.jpg") -Force
Remove-Item (Join-Path $hub "live\_bj.jpg"), (Join-Path $hub "live\_lightning_old.jpg") -Force

$pairs = @(
  @("roby-promo-slots.jpg", "assets\promo\promo-slots.jpg", 78, 1600),
  @("roby-promo-crash.jpg", "assets\promo\promo-crash.jpg", 78, 1600),
  @("roby-promo-live.jpg", "assets\promo\promo-live.jpg", 78, 1600),
  @("roby-promo-bonus.jpg", "assets\promo\promo-bonus.jpg", 78, 1600),
  @("roby-promo-odds.jpg", "assets\promo\promo-odds.jpg", 78, 1600),
  @("roby-promo-pay.jpg", "assets\promo\promo-pay.jpg", 78, 1600),
  @("roby-crash-01-spaceman.jpg", "assets\crash\crash-01.jpg", 80, 900),
  @("roby-crash-02-aviator.jpg", "assets\crash\crash-02.jpg", 80, 900),
  @("roby-crash-03-luckyjet.jpg", "assets\crash\crash-03.jpg", 80, 900),
  @("roby-crash-06-plinko.jpg", "assets\crash\crash-06.jpg", 80, 900),
  @("roby-slots-02-chaos-crew.jpg", "assets\slots\slots-02.jpg", 80, 900),
  @("roby-slots-03-sq2.jpg", "assets\slots\slots-03.jpg", 80, 900),
  @("roby-slots-09-punk.jpg", "assets\slots\slots-09.jpg", 80, 900),
  @("roby-slots-10-mt3.jpg", "assets\slots\slots-10.jpg", 80, 900),
  @("roby-live-02-megawheel.jpg", "assets\live\live-02.jpg", 80, 900),
  @("roby-live-03-lightning.jpg", "assets\live\live-03.jpg", 80, 900),
  @("roby-live-05-baccarat.jpg", "assets\live\live-05.jpg", 80, 900),
  @("roby-live-06-dream.jpg", "assets\live\live-06.jpg", 80, 900)
)
foreach ($p in $pairs) {
  $s = Join-Path $src $p[0]
  if (-not (Test-Path $s)) { throw "missing $s" }
  Save-Jpeg $s (Join-Path $dst $p[1]) $p[2] $p[3]
}

Write-Host "=== FILE SIZES ==="
Get-ChildItem $dst -Recurse -Include *.jpg,*.png,*.ico | Sort-Object FullName | ForEach-Object {
  "{0,10}  {1}" -f $_.Length, $_.FullName.Substring($dst.Length+1)
}
$total = (Get-ChildItem $dst -Recurse -Include *.jpg,*.png,*.ico | Measure-Object Length -Sum).Sum
Write-Host ("TOTAL_BYTES {0}" -f $total)
Write-Host ("TOTAL_MB {0:N2}" -f ($total/1MB))
