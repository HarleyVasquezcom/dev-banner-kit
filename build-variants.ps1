$ErrorActionPreference = 'Stop'

$dir = $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8($p){ [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8) }
function Write-Utf8($p, $c){ [System.IO.File]::WriteAllText($p, $c, $utf8) }

$snippetMobileEn = @'
  const snippet = [
    [['kw','const '],['var','project'],['punc',' = {']],
    [['ind','  '],['prop','idea'],['punc',': '],['str','"yours"'],['punc',',']],
    [['ind','  '],['prop','stack'],['punc',': '],['str','"modern"'],['punc',',']],
    [['ind','  '],['prop','speed'],['punc',': '],['str','"fast"']],
    [['punc','};']],
    [['fn','ship'],['punc','('],['var','project'],['punc',');']]
  ];
'@

$snippetMobileEs = @'
  const snippet = [
    [['kw','const '],['var','proyecto'],['punc',' = {']],
    [['ind','  '],['prop','idea'],['punc',': '],['str','"tuya"'],['punc',',']],
    [['ind','  '],['prop','stack'],['punc',': '],['str','"moderno"'],['punc',',']],
    [['ind','  '],['prop','speed'],['punc',': '],['str','"rápido"']],
    [['punc','};']],
    [['fn','lanzar'],['punc','('],['var','proyecto'],['punc',');']]
  ];
'@

$snippetStoryEn = @'
  const snippet = [
    [['kw','const '],['var','project'],['punc',' = {']],
    [['ind','  '],['prop','idea'],['punc',': '],['str','"yours"'],['punc',',']],
    [['ind','  '],['prop','stack'],['punc',': '],['str','"modern"'],['punc',',']],
    [['ind','  '],['prop','speed'],['punc',': '],['str','"fast"'],['punc',',']],
    [['ind','  '],['prop','launch'],['punc',': '],['str','"this week"']],
    [['punc','};']],
    [['fn','ship'],['punc','('],['var','project'],['punc',');']]
  ];
'@

$snippetStoryEs = @'
  const snippet = [
    [['kw','const '],['var','proyecto'],['punc',' = {']],
    [['ind','  '],['prop','idea'],['punc',': '],['str','"tuya"'],['punc',',']],
    [['ind','  '],['prop','stack'],['punc',': '],['str','"moderno"'],['punc',',']],
    [['ind','  '],['prop','speed'],['punc',': '],['str','"rápido"'],['punc',',']],
    [['ind','  '],['prop','launch'],['punc',': '],['str','"esta semana"']],
    [['punc','};']],
    [['fn','lanzar'],['punc','('],['var','proyecto'],['punc',');']]
  ];
'@

$fitStory = @'
  const story = document.getElementById('story');
  const stage = document.getElementById('stage');
  const fullSize = new URLSearchParams(location.search).has('full');

  function fit(){
    if (fullSize){
      story.style.transform = 'none';
      stage.style.width = '1080px';
      stage.style.height = '1920px';
      return;
    }
    const s = Math.min(window.innerWidth / 1080, (window.innerHeight - 32) / 1920);
    story.style.transform = 'scale(' + s + ')';
    stage.style.width = Math.round(1080 * s) + 'px';
    stage.style.height = Math.round(1920 * s) + 'px';
  }
  window.addEventListener('resize', fit);
  fit();
'@

$typeCore = @'
  const typed = document.getElementById('typed');
  const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const cursorEl = document.createElement('span');
  cursorEl.className = 'cursor';
  let typeTimer = null;
  let queue = [];
  let qi = 0;

  function buildQueue(lines){
    const q = [];
    lines.forEach(line => {
      line.forEach(tok => {
        const cls = tok[0];
        for (const ch of tok[1]) q.push([ch, cls]);
      });
      q.push(['\n', '']);
    });
    return q;
  }

  function startTyping(){
    clearInterval(typeTimer);
    queue = buildQueue(snippet);
    qi = 0;
    typed.innerHTML = '';
    typed.appendChild(cursorEl);
    const speed = reduce ? 0 : 22;
    typeTimer = setInterval(() => {
      if (qi >= queue.length){ clearInterval(typeTimer); return; }
      const [ch, cls] = queue[qi++];
      if (ch === '\n'){
        typed.appendChild(document.createTextNode('\n'));
      } else {
        const s = document.createElement('span');
        s.className = cls;
        s.textContent = ch;
        typed.appendChild(s);
      }
      typed.appendChild(cursorEl);
    }, speed);
  }

  startTyping();
'@

function New-Script($snippet, $withFit){
  $s = "<script>`n" + $snippet
  if ($withFit) { $s += $fitStory }
  $s += $typeCore + "</script>"
  return $s
}

function Convert-Variant($baseFile, $outFile, $lang, $isStory){
  $c = Read-Utf8 (Join-Path $dir $baseFile)

  if ($lang -eq 'en'){
    $c = $c -replace ' data-en="[^"]*" data-es="[^"]*"', ''
  } else {
    $c = $c -replace 'data-en="[^"]*" data-es="([^"]*)">[^<]*<', '>$1<'
  }

  $badge = '<div class="lang"><button class="lang-btn active" type="button">' + $lang.ToUpper() + '</button></div>'
  $c = $c -replace '(?s)<div class="lang" role="group" aria-label="Language">.*?</div>', $badge

  $c = $c -replace '\[data-en\]\{[^}]*\}\r?\n\s*\.switching \[data-en\]\{[^}]*\}\r?\n', ''

  $c = $c -replace '<html lang="[a-z]{2}">', ('<html lang="' + $lang + '">')

  $label = 'English'
  if ($lang -eq 'es'){ $label = 'Español' }
  $c = $c -replace '</title>', (' — ' + $label + '</title>')
  $c = $c -replace ' — auto-rotates EN / ES', (' — ' + $label)

  $snip = $snippetMobileEn
  if ($isStory -and $lang -eq 'en'){ $snip = $snippetStoryEn }
  if ($isStory -and $lang -eq 'es'){ $snip = $snippetStoryEs }
  if (-not $isStory -and $lang -eq 'es'){ $snip = $snippetMobileEs }

  $c = $c -replace '(?s)<script>.*?</script>', (New-Script $snip $isStory)

  Write-Utf8 (Join-Path $dir $outFile) $c
  Write-Output ("wrote " + $outFile)
}

Convert-Variant 'index.html' 'banner-en.html' 'en' $false
Convert-Variant 'index.html' 'banner-es.html' 'es' $false
Convert-Variant 'story.html' 'story-en.html' 'en' $true
Convert-Variant 'story.html' 'story-es.html' 'es' $true
