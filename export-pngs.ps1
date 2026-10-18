$ErrorActionPreference = 'Stop'

$dir = $PSScriptRoot
$outDir = Join-Path $dir 'exports'
if (!(Test-Path $outDir)){ New-Item -ItemType Directory -Path $outDir | Out-Null }

$candidates = @()
if (${env:ProgramFiles(x86)}){ $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe') }
if ($env:ProgramFiles){ $candidates += (Join-Path $env:ProgramFiles 'Microsoft\Edge\Application\msedge.exe') }
if ($env:ProgramFiles){ $candidates += (Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe') }
if (${env:ProgramFiles(x86)}){ $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Google\Chrome\Application\chrome.exe') }

$browser = $null
foreach ($c in $candidates){
  if (Test-Path $c){ $browser = $c; break }
}
if (-not $browser){ throw 'Microsoft Edge or Google Chrome not found.' }

$userData = Join-Path $env:TEMP 'traycer-banner-export'
if (!(Test-Path $userData)){ New-Item -ItemType Directory -Path $userData | Out-Null }

$targets = @(
  @{ File = 'banner-en.html'; W = 300;  H = 600;  Query = '?embed=1&still=1&flat=1'; Out = 'banner-en-300x600.png' },
  @{ File = 'banner-es.html'; W = 300;  H = 600;  Query = '?embed=1&still=1&flat=1'; Out = 'banner-es-300x600.png' },
  @{ File = 'story-en.html';  W = 1080; H = 1920; Query = '?full=1&still=1';  Out = 'story-en-1080x1920.png' },
  @{ File = 'story-es.html';  W = 1080; H = 1920; Query = '?full=1&still=1';  Out = 'story-es-1080x1920.png' },
  @{ File = 'post-en.html';   W = 1080; H = 1080; Query = '?full=1';          Out = 'post-en-1080x1080.png' },
  @{ File = 'post-es.html';   W = 1080; H = 1080; Query = '?full=1';          Out = 'post-es-1080x1080.png' }
)

Add-Type -AssemblyName System.Drawing

foreach ($t in $targets){
  $src = Join-Path $dir $t.File
  $uri = ([Uri]$src).AbsoluteUri + $t.Query
  $out = Join-Path $outDir $t.Out
  if (Test-Path $out){ Remove-Item -LiteralPath $out -Force }
  $bargs = @(
    '--headless=new',
    '--disable-gpu',
    '--hide-scrollbars',
    '--no-first-run',
    '--no-default-browser-check',
    '--force-prefers-reduced-motion',
    '--force-device-scale-factor=1',
    '--virtual-time-budget=5000',
    ('--user-data-dir=' + $userData),
    ('--window-size=' + ($t.W + 400) + ',' + ($t.H + 300)),
    ('--screenshot=' + $out),
    $uri
  )
  & $browser @bargs | Out-Null
  if (!(Test-Path $out)){ throw ('screenshot failed: ' + $t.Out) }
  $img = [System.Drawing.Bitmap]::FromFile($out)
  $rect = New-Object System.Drawing.Rectangle(0, 0, $t.W, $t.H)
  $crop = $img.Clone($rect, $img.PixelFormat)
  $img.Dispose()
  $crop.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $crop.Dispose()
  Write-Output ('exported ' + $t.Out)
}
