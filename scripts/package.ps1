$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$target = Join-Path $repo 'payload'
New-Item -ItemType Directory -Force $target | Out-Null
foreach ($name in @('app','scripts','deploy')) {
 Copy-Item -LiteralPath (Join-Path $repo $name) -Destination $target -Recurse -Force
}
Write-Host 'Payload ready. Run Terraform from terraform/.'
