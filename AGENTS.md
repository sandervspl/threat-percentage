# ThreatPercentage

For runtime or TOC compatibility changes, consult Gethe/wow-ui-source's `live` branch using `scripts/sync-wow-ui-source.sh live`. Treat the checkout in `.cache/wow-ui-source` as read-only; record the commit and relevant source files. Retail is the currently supported client.

Run `python scripts/verify.py` and `powershell -File scripts/verify-deploy.ps1` for runtime or deployment changes. Verification artifacts go in `dist/`. Keep deployment limited to supported clients and runtime files. Do not publish or push without user authorization.
