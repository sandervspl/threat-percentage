# Threat Percentage

Sets `threatShowNumeric` to `1` each time you log in or reload the UI. No settings, commands, or saved variables.

## Install

Extract `dist/ThreatPercentage.zip` into your Retail client's `Interface/AddOns` directory. The resulting folder must be `Interface/AddOns/ThreatPercentage`, containing `ThreatPercentage.toc` and `ThreatPercentage.lua`. Enable **Threat Percentage** in the addon list.

Retail interface metadata targets 12.1.5, based on the [UI source tags](https://github.com/Gethe/wow-ui-source/tags). If your client has a different interface version, enable **Load out of date AddOns**.

## Verify in game

With the addon enabled, run `/console threatShowNumeric 0`, then `/reload`. Run `/dump C_CVar.GetCVar("threatShowNumeric")`; it should report `"1"`. Check numeric threat on a hostile target during group combat. Disabling the addon does not reset the setting.

## Local verification

Failure modes: setting applied before login, wrong CVar or value, failure to restore a disabled setting after UI reload, or an incorrect ZIP folder layout.

Run `python -m pip install -r requirements-dev.txt`, then `python scripts/verify.py` and `powershell -File scripts/verify-deploy.ps1`. These exercise the shipped Lua and the deployment script in disposable client directories. Artifacts and the installable ZIP are written to `dist/`. Live in-game behavior still needs the smoke check above.

## Local deployment

Run `powershell -File scripts/copy-to-wow.ps1 -WhatIf` to preview discovered installations, then omit `-WhatIf` to install. You can supply `-WowRoot 'C:\Games\World of Warcraft'` or the `_retail_` client directory directly. Only installed Retail clients receive this addon; only its Lua and TOC are copied. Existing runtime files are overwritten.

## UI source reference

Run `bash scripts/sync-wow-ui-source.sh live` through Git Bash or WSL to fetch the read-only reference into `.cache/wow-ui-source`. The helper refuses to overwrite local changes and reports the upstream commit.

## CI and releases

GitHub Actions verifies the addon and local deployment on pushes and pull requests, retaining the results as downloadable artifacts. Pushing a `v*` tag runs the same checks, then BigWigsMods/packager creates a ZIP and publishes a GitHub release. The workflow needs repository Actions enabled and uses the built-in `GITHUB_TOKEN` with `contents: write`.

CurseForge and Wago publishing are not configured. To enable them later, add the actual project IDs to the TOC and map repository secrets to the packager's `CF_API_TOKEN` and `WAGO_API_TOKEN`. This project does not currently have a GitHub remote.
