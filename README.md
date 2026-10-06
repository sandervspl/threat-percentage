# Threat Percentage

Sets `threatShowNumeric` to `1` each time you log in or reload the UI. No settings, commands, or saved variables.

## Install

Extract `dist/ThreatPercentage.zip` into your chosen client's `Interface/AddOns` directory. The resulting folder must be `Interface/AddOns/ThreatPercentage`, containing `ThreatPercentage.toc` and `ThreatPercentage.lua`. Enable **Threat Percentage** in the addon list.

Supports current official live clients: Retail, Classic Era (including Hardcore and Season of Discovery), Burning Crusade Anniversary, and Mists of Pandaria Classic. One TOC lists interfaces 120100, 50504, 38002, 20506, 11509, and 16001, matching BuffTimers. This also covers the Titan (3.80.2) and Forever (1.60.1) client families. Actual in-game behavior still needs a smoke check on each client. Historical clients and private servers are not verified.

The CurseForge project description is in [CURSEFORGE_DESCRIPTION.md](CURSEFORGE_DESCRIPTION.md).

## Verify in game

With the addon enabled, run `/console threatShowNumeric 0`, then `/reload`. Run `/dump C_CVar.GetCVar("threatShowNumeric")`; it should report `"1"`. Check numeric threat on a hostile target during group combat. Disabling the addon does not reset the setting.

## Local verification

Failure modes: setting applied before login, wrong CVar or value, failure to restore a disabled setting after UI reload, or an incorrect ZIP folder layout.

Run `python -m pip install -r requirements-dev.txt`, then `python scripts/verify.py` and `powershell -File scripts/verify-deploy.ps1`. These exercise the shipped Lua and the deployment script in disposable client directories. Artifacts and the installable ZIP are written to `dist/`. Live in-game behavior still needs the smoke check above.

## Local deployment

Run `powershell -File scripts/copy-to-wow.ps1 -WhatIf` to preview discovered installations, then omit `-WhatIf` to install. You can supply `-WowRoot 'C:\Games\World of Warcraft'` or a client directory directly. Installed `_retail_`, `_classic_`, `_classic_era_`, `_anniversary_`, `_classic_titan_`, and `_classic_beta_` clients receive this addon; only its Lua and TOC are copied. Existing runtime files are overwritten.

## UI source reference

Run `bash scripts/sync-wow-ui-source.sh live` through Git Bash or WSL to fetch the read-only reference into `.cache/wow-ui-source`. The helper refuses to overwrite local changes and reports the upstream commit.

## CI and releases

GitHub Actions verifies the addon and local deployment on pushes and pull requests, retaining the results as downloadable artifacts. Pushing a `v*` tag runs the same checks, then BigWigsMods/packager reads the shared multi-interface TOC, creates a ZIP for all supported client families, and publishes a GitHub release. The workflow needs repository Actions enabled and uses the built-in `GITHUB_TOKEN` with `contents: write`.

CurseForge publishing targets project `1730539`. Add the CurseForge API token as repository secret `CF_API_KEY`; the workflow maps it to the packager's `CF_API_TOKEN`. Wago publishing is not configured.

## Compatibility source evidence

Inspected Gethe/wow-ui-source on 2026-10-06. The shared runtime uses `C_CVar.SetCVar`, documented in `Interface/AddOns/Blizzard_APIDocumentationGenerated/CVarDocumentation.lua` on each branch. Numeric threat is read in `Interface/AddOns/Blizzard_UnitFrame/Mainline/UnitFrame.lua` on Retail and Forever, and `Interface/AddOns/Blizzard_UnitFrame/Classic/UnitFrame.lua` on Classic. Classic also exposes the setting in `Interface/AddOns/Blizzard_SettingsDefinitions_Frame/Classic/InterfaceOverrides.lua`.

| Branch | Commit | Client version |
| --- | --- | --- |
| live | 09b9db7948abc9b9648dedaab51eb0cf3ee67b31 | 12.1.0 |
| classic_era | 8165d4cd6e48d606369336cc3a7977902310e81e | 1.15.9 |
| classic_anniversary | 1463c686270b6c64e2c5c228f447c4597c0f8ba6 | 2.5.6 |
| classic | a53b9b28857fd11184573f8dda6a746a789abc0e | 5.5.4 |
| classic_titan | 84ef503f0d2617494db84cc9c7e7b530e976f6e7 | 3.80.2 |
| forever | a84e2b1b41d3d4137127c07e4da448aa3251d6f1 | 1.60.1 |

Version numbers come from the branch commit subjects; Blizzard's own TOCs often use placeholder interface values. Run the in-game smoke check on each client before release. Automated checks verify Lua behavior and installation, not actual in-game rendering.
