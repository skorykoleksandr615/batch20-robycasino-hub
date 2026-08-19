$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$srcRoot = Join-Path $env:USERPROFILE ".cursor\projects\c-AndroidStudioProjects-batch20-hubs\assets"
$dstRoot = "C:\AndroidStudioProjects\batch20-hubs\robycasino"
if (-not (Test-Path $srcRoot)) {
  $alt = Get-ChildItem (Join-Path $env:USERPROFILE ".cursor\projects") -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*batch20-hubs*" } | Select-Object -First 1
  if ($alt) { $srcRoot = Join-Path $alt.FullName "assets" }
}
Write-Host "SRC=$srcRoot"
Write-Host "DST=$dstRoot"

$map = @{
  "roby-logo.png" = "assets\brand\logo.png"
  "roby-hero.jpg" = "assets\hero.jpg"
  "roby-og.jpg" = "assets\og.jpg"
  "promo-slots.jpg" = "assets\promo\promo-slots.jpg"
  "promo-crash.jpg" = "assets\promo\promo-crash.jpg"
  "promo-live.jpg" = "assets\promo\promo-live.jpg"
  "promo-odds.jpg" = "assets\promo\promo-odds.jpg"
  "promo-bonus.jpg" = "assets\promo\promo-bonus.jpg"
  "promo-pay.jpg" = "assets\promo\promo-pay.jpg"
  "page-login.jpg" = "assets\pages\roby-login.jpg"
  "page-join.jpg" = "assets\pages\roby-join.jpg"
  "page-bonus.jpg" = "assets\pages\roby-bonus.jpg"
  "page-slots.jpg" = "assets\pages\roby-slots.jpg"
  "page-odds.jpg" = "assets\pages\roby-odds.jpg"
  "page-crash.jpg" = "assets\pages\roby-crash.jpg"
  "page-live.jpg" = "assets\pages\roby-live.jpg"
  "page-app.jpg" = "assets\pages\roby-app.jpg"
  "page-pay.jpg" = "assets\pages\roby-pay.jpg"
  "page-help.jpg" = "assets\pages\roby-help.jpg"
}
1..10 | ForEach-Object { $map[("slots-{0:D2}.jpg" -f $_)] = ("assets\slots\slots-{0:D2}.jpg" -f $_) }
1..6 | ForEach-Object {
  $map[("crash-{0:D2}.jpg" -f $_)] = ("assets\crash\crash-{0:D2}.jpg" -f $_)
  $map[("live-{0:D2}.jpg" -f $_)] = ("assets\live\live-{0:D2}.jpg" -f $_)
}

function Save-Jpeg($img, $path, $quality, $maxW) {
  $clone = $img
  if ($img.Width -gt $maxW) {
    $nh = [int]($img.Height * $maxW / $img.Width)
    $clone = New-Object System.Drawing.Bitmap $maxW, $nh
    $g = [System.Drawing.Graphics]::FromImage($clone)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($img, 0, 0, $maxW, $nh)
    $g.Dispose()
  }
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
  $clone.Save($path, $codec, $ep)
  if ($clone -ne $img) { $clone.Dispose() }
}

$missing = @()
foreach ($k in $map.Keys) {
  $s = Join-Path $srcRoot $k
  $d = Join-Path $dstRoot $map[$k]
  $dir = Split-Path $d -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  if (-not (Test-Path $s)) { $missing += $s; continue }
  if ($k -like "*.png") {
    $im = [System.Drawing.Image]::FromFile($s)
    $side = 512
    $scale = [Math]::Min($side / $im.Width, $side / $im.Height)
    $nw = [Math]::Max(1, [int]($im.Width * $scale))
    $nh = [Math]::Max(1, [int]($im.Height * $scale))
    $bmp = New-Object System.Drawing.Bitmap $nw, $nh
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($im, 0, 0, $nw, $nh)
    $g.Dispose()
    $im.Dispose()
    $bmp.Save($d, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
  } else {
    $im = [System.Drawing.Image]::FromFile($s)
    $maxW = 1200
    if ($map[$k] -match "promo|og|pages") { $maxW = 1600 }
    if ($map[$k] -match "hero") { $maxW = 1100 }
    $q = 80
    if ($map[$k] -match "promo|hero|pages") { $q = 78 }
    Save-Jpeg $im $d $q $maxW
    $im.Dispose()
  }
}

$logo = Join-Path $dstRoot "assets\brand\logo.png"
if (Test-Path $logo) {
  $base = [System.Drawing.Image]::FromFile($logo)
  $sizes = @{
    "favicon-32.png" = 32
    "favicon-48x48.png" = 48
    "favicon-96x96.png" = 96
    "favicon-192x192.png" = 192
    "apple-touch-icon.png" = 180
  }
  foreach ($name in $sizes.Keys) {
    $sz = $sizes[$name]
    $canvas = New-Object System.Drawing.Bitmap $sz, $sz
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    $g.Clear([System.Drawing.Color]::FromArgb(255, 11, 6, 32))
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $scale = [Math]::Min($sz / $base.Width, $sz / $base.Height)
    $nw = [int]($base.Width * $scale)
    $nh = [int]($base.Height * $scale)
    $x = [int](($sz - $nw) / 2)
    $y = [int](($sz - $nh) / 2)
    $g.DrawImage($base, $x, $y, $nw, $nh)
    $g.Dispose()
    $out = Join-Path $dstRoot $name
    $canvas.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Dispose()
  }
  $icoBmp = New-Object System.Drawing.Bitmap 32, 32
  $g2 = [System.Drawing.Graphics]::FromImage($icoBmp)
  $g2.Clear([System.Drawing.Color]::FromArgb(255, 11, 6, 32))
  $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g2.DrawImage($base, 0, 0, 32, 32)
  $g2.Dispose()
  $tmpPng = Join-Path $dstRoot "_tmp_fav.png"
  $icoBmp.Save($tmpPng, [System.Drawing.Imaging.ImageFormat]::Png)
  $icoBmp.Dispose()
  $base.Dispose()
  # ico via copy of 32 png as favicon.ico fallback (png-named ico still ok for modern browsers we also have png icons)
  Copy-Item $tmpPng (Join-Path $dstRoot "favicon.ico") -Force
  Remove-Item $tmpPng -Force
}

Write-Host "=== FILE SIZES ==="
Get-ChildItem $dstRoot -Recurse -Include *.jpg,*.png,*.ico | Sort-Object FullName | ForEach-Object {
  "{0,10}  {1}" -f $_.Length, $_.FullName.Substring($dstRoot.Length+1)
}
$total = (Get-ChildItem $dstRoot -Recurse -Include *.jpg,*.png,*.ico | Measure-Object Length -Sum).Sum
Write-Host ("TOTAL_BYTES {0}" -f $total)
Write-Host ("TOTAL_MB {0:N2}" -f ($total/1MB))
if ($missing.Count) { Write-Host "MISSING SOURCE:"; $missing | ForEach-Object { Write-Host $_ }; exit 1 }
