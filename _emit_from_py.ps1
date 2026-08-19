$ErrorActionPreference = "Stop"
$ROOT = "C:\AndroidStudioProjects\batch20-hubs\robycasino"
$files = @(
  (Join-Path $ROOT "_i18n_build.py"),
  (Join-Path $ROOT "_i18n_rest.py"),
  (Join-Path $ROOT "_i18n_rest2.py")
)
$langs = @("de","ru","uk","pl","es","pt","fr","it","tr","nl")
$phrases = [ordered]@{}

function Unescape([string]$s) {
  $s = $s -replace '\\"', '"'
  $s = $s -replace '\\n', "`n"
  return $s
}

foreach ($f in $files) {
  if (-not (Test-Path $f)) { continue }
  $lines = Get-Content $f -Encoding UTF8
  foreach ($line in $lines) {
    $t = $line.Trim()
    if (-not $t.StartsWith("t(")) { continue }
    if ($t -notmatch '^t\("((?:\\.|[^"\\])*)"') { continue }
    $en = Unescape $Matches[1]
    $pack = [ordered]@{}
    $ok = $true
    foreach ($lg in $langs) {
      $re = [regex]::new("$lg=`"((?:\\.|[^`"\\])*)`"")
      $m = $re.Match($t)
      if (-not $m.Success) { $ok = $false; break }
      $pack[$lg] = Unescape $m.Groups[1].Value
    }
    if ($ok) { $phrases[$en] = $pack }
  }
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("(function(){")
[void]$sb.AppendLine("var d=window.HUB_I18N_DICT; if(!d||!d.phrases) return;")
[void]$sb.AppendLine("var add={")
foreach ($en in $phrases.Keys) {
  $enJson = ($en | ConvertTo-Json -Compress)
  $packJson = ($phrases[$en] | ConvertTo-Json -Compress)
  [void]$sb.AppendLine((' {0}:{1},' -f $enJson, $packJson))
}
[void]$sb.AppendLine("};")
[void]$sb.AppendLine("Object.keys(add).forEach(function(k){ d.phrases[k]=add[k]; });")
[void]$sb.AppendLine("})();")
$out = Join-Path $ROOT "js\i18n-from-py.js"
[IO.File]::WriteAllText($out, $sb.ToString(), [Text.UTF8Encoding]::new($false))
Write-Host ("phrases {0} -> {1} bytes {2}" -f $phrases.Count, $out, (Get-Item $out).Length)
