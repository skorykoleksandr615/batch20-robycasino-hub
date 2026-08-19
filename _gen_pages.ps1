$ErrorActionPreference = "Stop"
$ROOT = "C:\AndroidStudioProjects\batch20-hubs\robycasino"
$OFFER = "https://dscdscds913.online/RwrNbHMF?sub_id_1=robycasino"
$DOMAIN = "roby.casino"
$BRAND = "Roby Casino"
$LANGS = @("en","de","ru","uk","pl","es","pt","fr","it","tr","nl")
$NAV = @(
  @("/", "Home"),
  @("/roby-login.html", "Login"),
  @("/roby-join.html", "Register"),
  @("/roby-bonus.html", "Bonus"),
  @("/roby-slots.html", "Slots"),
  @("/roby-odds.html", "Odds"),
  @("/roby-crash.html", "Crash"),
  @("/roby-live.html", "Live"),
  @("/roby-app.html", "App"),
  @("/roby-pay.html", "Pay"),
  @("/roby-help.html", "Help")
)

function Hreflang($file) {
  $rows = $LANGS | ForEach-Object { "<link rel=`"alternate`" hreflang=`"$_`" href=`"https://$DOMAIN/$file?lang=$_`">" }
  ($rows -join "`n") + "`n<link rel=`"alternate`" hreflang=`"x-default`" href=`"https://$DOMAIN/$file`">"
}

function Header($active) {
  $links = ($NAV | ForEach-Object {
    $cls = if ($_[0] -eq $active) { "nav-link is-active" } else { "nav-link" }
    "<a class=`"$cls`" href=`"$($_[0])`">$($_[1])</a>"
  }) -join ""
  @"
<body class="page">
<header class="site-header" id="siteHeader">
<div class="hex-spark" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i></div>
<div class="wrap header-bar">
<a class="brand" href="/" aria-label="Roby Casino home">
<span class="brand-mark"><img src="/assets/brand/logo.png" alt="Roby Casino logo" width="46" height="46"></span>
<span class="brand-copy"><span class="brand-name">Roby Casino</span><span class="brand-tag">Official</span></span>
</a>
<button class="nav-toggle" id="navToggle" aria-expanded="false" aria-controls="siteNav" type="button" aria-label="Open menu"><span></span><span></span><span></span></button>
<nav class="site-nav" id="siteNav" aria-label="Primary">$links</nav>
<div class="header-actions"><div class="lang-switch" id="langSwitch"><button type="button" class="lang-switch-btn" aria-haspopup="listbox" aria-expanded="false" aria-label="Language"><img class="lang-flag-img" src="https://flagcdn.com/w40/gb.png" width="22" height="16" alt="English flag" loading="lazy" decoding="async"><span class="lang-code">EN</span><span class="lang-name" data-i18n-skip="1">English</span></button><div class="lang-switch-panel" role="listbox"></div></div><a class="btn btn-accent header-cta" href="$OFFER" rel="nofollow sponsored noopener" target="_blank">Play Now</a></div>
</div>
</header>
"@
}

$FOOT = @"
<section class="related wrap"><div class="section-head"><h2>Explore more</h2></div><div class="chip-row"><a class="chip" href="/roby-join.html">Register</a><a class="chip" href="/roby-bonus.html">Bonus</a><a class="chip" href="/roby-slots.html">Slots</a><a class="chip" href="/roby-crash.html">Crash</a><a class="chip" href="/roby-live.html">Live Casino</a><a class="chip" href="/roby-odds.html">Sports Odds</a></div></section>
<section class="cta-band"><div class="wrap"><h2>Ready for Roby Casino?</h2><p class="mute">Official path to slots, crash, live tables and the cashier.</p><div class="cta-row"><a class="btn btn-accent" href="$OFFER" rel="nofollow sponsored noopener" target="_blank">Open Lobby</a><a class="btn btn-ghost" href="$OFFER" rel="nofollow sponsored noopener" target="_blank">Play Now</a></div></div></section>
<footer class="site-footer"><div class="wrap footer-grid"><div><div class="footer-brand">Roby Casino</div><p class="mute">Hub for login, slots, crash, live casino, sports odds and cashier on roby.casino.</p><a class="btn btn-accent" href="$OFFER" rel="nofollow sponsored noopener" target="_blank">Play Now</a></div><div class="footer-links"><a href="/roby-login.html">Login</a><a href="/roby-join.html">Register</a><a href="/roby-bonus.html">Bonus</a><a href="/roby-slots.html">Slots</a><a href="/roby-odds.html">Sports Odds</a><a href="/roby-crash.html">Crash</a><a href="/roby-live.html">Live Casino</a><a href="/roby-app.html">App</a><a href="/roby-pay.html">Payments</a><a href="/roby-help.html">Help</a></div></div>
<div class="wrap footer-base"><span>&copy; 2026 Roby Casino</span><span>18+</span><span>Responsible play</span></div></footer>
<script src="/js/hex.js"></script>
<script src="/js/i18n-dict.js"></script>
<script src="/js/i18n-from-py.js"></script>
<script src="/js/i18n-more.js"></script>
<script src="/js/i18n-extra.js"></script>
<script src="/js/i18n-extra2.js"></script>
<script src="/js/i18n-extra3.js"></script>
<script src="/js/i18n-extra4.js"></script>
<script src="/js/i18n.js"></script>
</body>
</html>
"@

function JsonFaq($faqs, $url) {
  $ent = @()
  foreach ($f in $faqs) {
    $q = ($f[0] | ConvertTo-Json -Compress)
    $a = ($f[1] | ConvertTo-Json -Compress)
    $ent += "{`"@type`":`"Question`",`"name`":$q,`"acceptedAnswer`":{`"@type`":`"Answer`",`"text`":$a}}"
  }
  "{`"`@context`":`"https://schema.org`",`"`@type`":`"FAQPage`",`"url`":$(($url | ConvertTo-Json -Compress)),`"mainEntity`":[$($ent -join ',')]}"
}

function Write-Page($p) {
  $file = $p.file
  $url = "https://$DOMAIN/$file"
  $faqJson = JsonFaq $p.faqs $url
  $hl = Hreflang $file
  $head = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$($p.title)</title>
<meta name="description" content="$($p.desc)">
<meta name="keywords" content="$($p.keywords)">
<meta name="robots" content="index,follow,max-image-preview:large">
<link rel="canonical" href="$url">
$hl
<meta property="og:type" content="website">
<meta property="og:site_name" content="$BRAND">
<meta property="og:title" content="$($p.title)">
<meta property="og:description" content="$($p.desc)">
<meta property="og:url" content="$url">
<meta property="og:image" content="https://$DOMAIN/assets/og.jpg">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="$($p.title)">
<meta name="twitter:description" content="$($p.desc)">
<meta name="twitter:image" content="https://$DOMAIN/assets/og.jpg">
<link rel="icon" href="/favicon.ico" sizes="any">
<link rel="icon" type="image/png" sizes="48x48" href="/favicon-48x48.png">
<link rel="icon" type="image/png" sizes="96x96" href="/favicon-96x96.png">
<link rel="icon" type="image/png" sizes="192x192" href="/favicon-192x192.png">
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@600;800&family=Sora:wght@400;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/css/styles.css">
<link rel="stylesheet" href="/css/i18n.css">
<script type="application/ld+json">$faqJson</script>
</head>
"@
  $n = 0
  $chHtml = ($p.chs | ForEach-Object {
    $n++
    $nn = "{0:D2}" -f $n
    "<article class=`"chapter`"><div class=`"chapter-n`">$nn</div><h3>$($_[0])</h3><p>$($_[1])</p><p>$($_[2])</p></article>"
  }) -join ""
  $chapters = "<section class=`"section wrap`"><div class=`"section-head`"><h2>Guide chapters</h2><p class=`"mute`">Practical steps for players.</p></div><div class=`"chapter-grid`">$chHtml</div></section>"
  $faqHtml = ($p.faqs | ForEach-Object { "<details class=`"faq-item`"><summary>$($_[0])</summary><p>$($_[1])</p></details>" }) -join ""
  $faqSec = "<section class=`"faq wrap`" id=`"faq`"><div class=`"section-head`"><h2>FAQ</h2><p class=`"mute`">Straight answers for login, bonus, slots, crash, live and cashier.</p></div><div class=`"faq-list`">$faqHtml</div></section>"
  $body = (Header "/$file") + @"
<section class="page-hero"><div class="wrap"><div class="page-hero-shell"><div class="page-hero-copy"><div class="eyebrow">$($p.eyebrow)</div>
<h1>$($p.h1)<span>$($p.span)</span></h1>
<p class="lead">$($p.lead)</p>
<div class="cta-row">
<a class="btn btn-accent" href="$OFFER" rel="nofollow sponsored noopener" target="_blank">$($p.cta)</a>
<a class="btn btn-ghost" href="$OFFER" rel="nofollow sponsored noopener" target="_blank">Play Now</a>
</div></div><div class="page-hero-visual reveal"><img class="hero-img" src="$($p.cover)" alt="$($p.cover_alt)" width="1280" height="720" loading="eager"></div></div></div></section>
<div class="wrap"><a class="promo-fx reveal" href="$OFFER" rel="nofollow sponsored noopener" target="_blank"><span class="promo-badge">$($p.promo_badge)</span><div class="promo-media"><img src="$($p.promo_img)" alt="$($p.promo_alt)" width="1920" height="1080" loading="lazy"></div><div class="promo-copy"><span class="promo-kicker">$($p.kicker)</span><div class="promo-title">$($p.ptitle)</div><p class="promo-sub">$($p.psub)</p></div><span class="promo-cta">$($p.pcta)</span></a></div>
"@
  $html = $head + $body + $chapters + $faqSec + $FOOT
  [IO.File]::WriteAllText((Join-Path $ROOT $file), $html, [Text.UTF8Encoding]::new($false))
  Write-Host "wrote $file"
}

# Load page objects
. (Join-Path $ROOT "_pages_data.ps1")
foreach ($p in $script:Pages) {
  Write-Page $p
}
