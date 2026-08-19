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
      if (-not $m.Success) { $ok = $false; Write-Host "MISS $lg :: $($en.Substring(0,[Math]::Min(60,$en.Length)))"; break }
      $pack[$lg] = Unescape $m.Groups[1].Value
    }
    if ($ok) { $phrases[$en] = $pack }
  }
}

$identity = @(
  "Wanted Dead or a Wild","Chaos Crew 2","San Quentin 2","Mental","Duel at Dawn","Le Bandit","Tombstone RIP","Fire in the Hole 2","Punk Rocker","Money Train 3",
  "Spaceman","Aviator","Lucky Jet","JetX","Aviatrix","Plinko","Crazy Time","Mega Wheel","Lightning Roulette","Blackjack","Baccarat","Dream Catcher",
  "Nolimit City","Hacksaw Gaming","Pragmatic Play","Evolution","NetEnt","Play'n GO","Relax Gaming","Push Gaming",
  "Liverpool","Man City","Chelsea","Tottenham","Real Madrid","PSG","Barcelona","Sevilla","Juventus","AC Milan","Bayern Munich","Dortmund","Lyon","Ajax","Lakers","Warriors","Rangers","Hurricanes",
  "LIV","MCI","CHE","TOT","RMA","BAR","SEV","JUV","MIL","BAY","DOR","OL","AJA","PSV","LAL","GSW","NYR","CAR"
)
foreach ($name in $identity) {
  if (-not $phrases.Contains($name)) {
    $p = [ordered]@{}
    foreach ($lg in $langs) { $p[$lg] = $name }
    $phrases[$name] = $p
  }
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("window.HUB_I18N_DICT = {")
[void]$sb.AppendLine(" meta: {")
[void]$sb.AppendLine(' en:{name:"English",flag:"🇬🇧",code:"gb"},')
[void]$sb.AppendLine(' de:{name:"Deutsch",flag:"🇩🇪",code:"de"},')
[void]$sb.AppendLine(' ru:{name:"Русский",flag:"🇷🇺",code:"ru"},')
[void]$sb.AppendLine(' uk:{name:"Українська",flag:"🇺🇦",code:"ua"},')
[void]$sb.AppendLine(' pl:{name:"Polski",flag:"🇵🇱",code:"pl"},')
[void]$sb.AppendLine(' es:{name:"Español",flag:"🇪🇸",code:"es"},')
[void]$sb.AppendLine(' pt:{name:"Português",flag:"🇵🇹",code:"pt"},')
[void]$sb.AppendLine(' fr:{name:"Français",flag:"🇫🇷",code:"fr"},')
[void]$sb.AppendLine(' it:{name:"Italiano",flag:"🇮🇹",code:"it"},')
[void]$sb.AppendLine(' tr:{name:"Türkçe",flag:"🇹🇷",code:"tr"},')
[void]$sb.AppendLine(' nl:{name:"Nederlands",flag:"🇳🇱",code:"nl"}')
[void]$sb.AppendLine(" },")
[void]$sb.AppendLine(" phrases: {")
foreach ($en in $phrases.Keys) {
  $enJson = ($en | ConvertTo-Json -Compress)
  $packJson = ($phrases[$en] | ConvertTo-Json -Compress)
  [void]$sb.AppendLine((' {0}: {1},' -f $enJson, $packJson))
}
[void]$sb.AppendLine(" }")
[void]$sb.AppendLine("};")
$out = Join-Path $ROOT "js\i18n-dict.js"
[IO.File]::WriteAllText($out, $sb.ToString(), [Text.UTF8Encoding]::new($false))
Write-Host ("phrases {0} -> {1}" -f $phrases.Count, $out)
