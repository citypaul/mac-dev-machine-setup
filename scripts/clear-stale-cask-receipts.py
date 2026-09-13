#!/usr/bin/env python3
"""Clear Homebrew cask records whose installed files have gone missing.

When an app is deleted outside Homebrew (dragged to the Bin, removed by a
cleanup tool), brew keeps its install receipt and still reports the cask as
installed. `brew bundle` trusts that record, so it skips the cask and the app
stays missing.

For every cask in the given Brewfiles that brew records as installed, this
checks each file the cask puts on disk (apps, binaries, manpages,
completions). If any is missing it force-uninstalls the cask, clearing the
stale record so the `brew bundle` run that follows installs it fresh.

A cask with nothing checkable (a pkg-only installer) is never cleared. The
check uses the current cask definition, so a cask whose latest version renamed
its app is also cleared, and reinstalled at that latest version.

Usage: scripts/clear-stale-cask-receipts.py [--dry-run] BREWFILE [BREWFILE ...]

Prints `CLEARED: <casks>` when it clears anything (`STALE: <casks>` with
--dry-run, which uninstalls nothing).
"""
import argparse
import json
import os
import subprocess
import sys


def stale_casks(casks, exists):
    """Tokens of installed casks with at least one installed file missing."""
    return [
        cask["token"]
        for cask in casks
        if cask.get("installed")
        and any(
            not exists(artifact["target"])
            for artifact in cask["artifacts"]
            if "target" in artifact
        )
    ]


def brew(*args):
    result = subprocess.run(["brew", *args], capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f"brew {' '.join(args)} failed:\n{result.stderr.strip()}")
    return result.stdout


def brewfile_casks(brewfiles):
    names = []
    for brewfile in brewfiles:
        names += brew("bundle", "list", "--cask", f"--file={brewfile}").split()
    return names


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("brewfiles", nargs="+", metavar="BREWFILE")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    names = brewfile_casks(args.brewfiles)
    if not names:
        return
    casks = json.loads(brew("info", "--cask", "--json=v2", *names))["casks"]
    # os.path.exists is False for a dangling symlink, which is what a deleted
    # app leaves behind in the Caskroom.
    stale = stale_casks(casks, os.path.exists)
    if not stale:
        return

    if args.dry_run:
        print(f"STALE: {', '.join(stale)}")
        return
    for token in stale:
        brew("uninstall", "--cask", "--force", token)
    print(f"CLEARED: {', '.join(stale)}")


if __name__ == "__main__":
    main()
