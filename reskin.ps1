param(
  [string]$Brand,
  [string]$Domain,
  [string]$DomainEs,
  [string]$Email,
  [string]$C1,
  [string]$C2,
  [string]$C3,
  [string]$C4,
  [string]$C5
)

$ErrorActionPreference = 'Stop'

$dir = $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)
$jsonPath = Join-Path $dir 'brand.json'

function Read-Utf8($p){ [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8) }
function Write-Utf8($p, $c){ [System.IO.File]::WriteAllText($p, $c, $utf8) }
function Triplet($hex){
  $h = $hex.TrimStart('#')
  '{0},{1},{2}' -f [Convert]::ToInt32($h.Substring(0,2),16), [Convert]::ToInt32($h.Substring(2,2),16), [Convert]::ToInt32($h.Substring(4,2),16)
}

$cfg = Read-Utf8 $jsonPath | ConvertFrom-Json

$oldBrand    = $cfg.brand
$oldDomain   = $cfg.domain
$oldDomainEs = $cfg.domainEs
$oldEmail    = $cfg.email

if (-not $Brand){ $Brand = $oldBrand }
if (-not $DomainEs){ $DomainEs = $oldDomainEs }
if (-not $Domain){ $Domain = $oldDomain }
if (-not $Email){ $Email = $oldEmail.Split('@')[0] + '@' + $Domain }
if (-not $C1){ $C1 = $cfg.c1 }
if (-not $C2){ $C2 = $cfg.c2 }
if (-not $C3){ $C3 = $cfg.c3 }
if (-not $C4){ $C4 = $cfg.c4 }
if (-not $C5){ $C5 = $cfg.c5 }

$pairs = @(
  @{ Old = $cfg.c1; New = $C1 },
  @{ Old = $cfg.c2; New = $C2 },
  @{ Old = $cfg.c3; New = $C3 },
  @{ Old = $cfg.c4; New = $C4 },
  @{ Old = $cfg.c5; New = $C5 }
)

$files = Get-ChildItem -Path $dir -File | Where-Object { $_.Extension -eq '.html' -or $_.Extension -eq '.md' }

foreach ($f in $files){
  $c = Read-Utf8 $f.FullName
  $orig = $c
  $c = $c.Replace($oldEmail, $Email)
  $c = $c.Replace($oldDomainEs, $DomainEs)
  $c = $c.Replace($oldDomain, $Domain)
  $c = $c.Replace($oldBrand, $Brand)
  foreach ($p in $pairs){
    if ($p.Old -ne $p.New){
      $c = $c.Replace($p.Old, $p.New)
      $c = $c.Replace((Triplet $p.Old), (Triplet $p.New))
    }
  }
  if ($c -ne $orig){
    Write-Utf8 $f.FullName $c
    Write-Output ('updated ' + $f.Name)
  } else {
    Write-Output ('unchanged ' + $f.Name)
  }
}

$newCfg = [ordered]@{
  brand = $Brand; domain = $Domain; domainEs = $DomainEs; email = $Email
  c1 = $C1; c2 = $C2; c3 = $C3; c4 = $C4; c5 = $C5
}
Write-Utf8 $jsonPath (($newCfg | ConvertTo-Json) + "`n")
Write-Output ('brand.json updated: ' + $Brand + ' | ' + $Domain + ' | ' + $Email + ' | ' + $C1 + ',' + $C2 + ',' + $C3 + ',' + $C4 + ',' + $C5)
