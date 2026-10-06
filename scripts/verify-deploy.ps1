# Failure modes: WhatIf writes files, unsupported clients receive the addon,
# duplicate roots cause repeated copies, source files are missing or corrupted,
# explicit invalid roots silently succeed, or deployment copies development files.
$ErrorActionPreference = 'Stop'
$sourceRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) ('ThreatPercentage-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $fixtureRoot | Out-Null
foreach ($flavor in @('_retail_', '_classic_', '_classic_era_')) {
    $client = Join-Path $fixtureRoot $flavor
    New-Item -ItemType Directory -Path $client | Out-Null
    Set-Content -LiteralPath (Join-Path $client '.flavor.info') -Value $flavor
}
& "$PSScriptRoot/copy-to-wow.ps1" -WowRoot $fixtureRoot -WhatIf
$addon = Join-Path $fixtureRoot '_retail_/Interface/AddOns/ThreatPercentage'
if (Test-Path -LiteralPath $addon) { throw 'WhatIf created the addon directory.' }
& "$PSScriptRoot/copy-to-wow.ps1" -WowRoot @($fixtureRoot, (Join-Path $fixtureRoot '_retail_'))
foreach ($name in @('ThreatPercentage.lua', 'ThreatPercentage.toc')) {
    if ((Get-FileHash -LiteralPath (Join-Path $addon $name)).Hash -ne
        (Get-FileHash -LiteralPath (Join-Path $sourceRoot $name)).Hash) { throw "Incorrect copy: $name" }
}
if (@(Get-ChildItem -LiteralPath $addon -File).Count -ne 2) { throw 'Unexpected deployed files.' }
foreach ($flavor in @('_classic_', '_classic_era_')) {
    if (Test-Path -LiteralPath (Join-Path $fixtureRoot "$flavor/Interface")) { throw 'Unsupported client was modified.' }
}
$rejected = $false
try { & "$PSScriptRoot/copy-to-wow.ps1" -WowRoot (Join-Path $fixtureRoot 'missing') }
catch { $rejected = $true }
if (-not $rejected) { throw 'Missing explicit root was accepted.' }
$artifact = Join-Path $sourceRoot 'dist/deploy-verification.txt'
New-Item -ItemType Directory -Path (Split-Path $artifact) -Force | Out-Null
@("Command: powershell -File scripts/verify-deploy.ps1", "PASS: WhatIf, mixed client discovery, duplicate roots, runtime hashes, missing root rejection.", "Fixture: $fixtureRoot") | Set-Content -LiteralPath $artifact
Write-Host "PASS: deployment verified. Artifact: $artifact"
