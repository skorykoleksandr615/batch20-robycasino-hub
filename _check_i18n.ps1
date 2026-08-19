$ErrorActionPreference = "Stop"
$ROOT = "C:\AndroidStudioProjects\batch20-hubs\robycasino"
$keys = New-Object "System.Collections.Generic.HashSet[string]"
Get-ChildItem (Join-Path $ROOT "js") -Filter "i18n*.js" | ForEach-Object {
  if ($_.Name -eq "i18n.js") { return }
  $txt = [IO.File]::ReadAllText($_.FullName)
  [regex]::Matches($txt, '"((?:\\.|[^"\\])*)"\s*:') | ForEach-Object {
    $k = $_.Groups[1].Value.Replace('\"','"')
    if ($k.Length -ge 2 -and $k -notin @("de","ru","uk","pl","es","pt","fr","it","tr","nl","en","name","code","flag","phrases","meta")) {
      [void]$keys.Add($k)
    }
  }
}
function Get-Texts($path) {
  $raw = [IO.File]::ReadAllText($path)
  if ($raw -match '(?is)<body[\s\S]*') { $raw = $Matches[0] }
  $raw = [regex]::Replace($raw, '(?is)<(script|style|noscript)[\s\S]*?</\1>', ' ')
  $raw = [regex]::Replace($raw, '(?s)<!--.*?-->', ' ')
  $raw = [regex]::Replace($raw, '<[^>]+>', "`n")
  $raw = [System.Net.WebUtility]::HtmlDecode($raw)
  $out = @()
  foreach ($line in $raw -split "`n") {
    $t = ($line -replace '\s+', ' ').Trim()
    if ($t.Length -ge 3) { $out += $t }
  }
  return $out
}
$missing = @()
$seen = New-Object "System.Collections.Generic.HashSet[string]"
Get-ChildItem $ROOT -Filter "*.html" | ForEach-Object {
  foreach ($t in (Get-Texts $_.FullName)) {
    if (-not $seen.Add($t)) { continue }
    if ($t -match '^[\d\s.,:%+\-–—|/©×xX]+$') { continue }
    $n = $t.Replace("Roby Casino", "{Brand}").Replace("roby.casino", "{Domain}")
    if (-not $keys.Contains($n) -and -not $keys.Contains($t)) { $missing += $n }
  }
}
[IO.File]::WriteAllText((Join-Path $ROOT "_missing.txt"), ($missing -join "`n"), [Text.UTF8Encoding]::new($false))
Write-Host ("keys={0} unique_texts={1} missing={2}" -f $keys.Count, $seen.Count, $missing.Count)
$missing
