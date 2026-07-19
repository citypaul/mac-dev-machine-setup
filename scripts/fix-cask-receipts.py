#!/usr/bin/env python3
"""Repair corrupted Homebrew cask install receipts.

Some Homebrew versions wrote empty ({}) cask receipts under
/opt/homebrew/Caskroom/<cask>/.metadata/<version>/<ts>/Casks/<cask>.json.
With an empty receipt `brew upgrade` sees zero artifacts for the installed
version, never removes the old app, and fails with:

    Error: <cask>: It seems there is already an App at '/Applications/<App>.app'

This script finds every cask whose newest receipt is empty and rewrites it
from the current cask API definition (`brew info --cask --json=v2`), with the
version field set to the installed version so uninstall-on-upgrade purges the
right Caskroom directory. It downloads nothing and only touches receipts that
are empty.

Usage: scripts/fix-cask-receipts.py

Casks from untrusted third-party taps are reported as failures; run the
suggested `brew trust <tap>` command and re-run this script.
"""
import json
import subprocess
from pathlib import Path

CASKROOM = Path("/opt/homebrew/Caskroom")


def latest_receipt(cask_dir: Path):
    meta = cask_dir / ".metadata"
    if not meta.is_dir():
        return None
    receipts = sorted(
        p for p in meta.rglob("*.json")
        if p.name not in ("config.json", "INSTALL_RECEIPT.json")
    )
    return receipts[-1] if receipts else None


def installed_version(cask_dir: Path):
    versions = sorted(
        d.name for d in cask_dir.iterdir()
        if d.is_dir() and d.name != ".metadata" and not d.name.endswith(".upgrading")
    )
    return versions[-1] if versions else None


def main():
    fixed, failed = [], []
    for cask_dir in sorted(CASKROOM.iterdir()):
        if not cask_dir.is_dir() or cask_dir.name == ".metadata":
            continue
        token = cask_dir.name
        receipt = latest_receipt(cask_dir)
        if receipt is None or receipt.stat().st_size > 4:
            continue
        info = subprocess.run(
            ["brew", "info", "--cask", token, "--json=v2"],
            capture_output=True, text=True,
        )
        if info.returncode != 0:
            stderr = info.stderr.strip()
            failed.append((token, stderr.splitlines()[-1] if stderr else "brew info failed"))
            continue
        try:
            cask = json.loads(info.stdout)["casks"][0]
        except (json.JSONDecodeError, KeyError, IndexError) as e:
            failed.append((token, f"bad json: {e}"))
            continue
        version = installed_version(cask_dir)
        if version:
            cask["version"] = version
        receipt.write_text(json.dumps(cask))
        fixed.append(token)

    print(f"FIXED ({len(fixed)}): {', '.join(fixed) or 'none'}")
    if failed:
        print(f"FAILED ({len(failed)}):")
        for token, err in failed:
            print(f"  {token}: {err}")
        raise SystemExit(1)


if __name__ == "__main__":
    main()
