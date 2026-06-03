#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 BREWFILE" >&2
  exit 64
fi

brewfile="$1"
keepalive_interval="${SUDO_KEEPALIVE_INTERVAL:-60}"

/usr/bin/sudo -v
/usr/bin/sudo -n -v

(
  while true; do
    sleep "$keepalive_interval"
    /usr/bin/sudo -n -v || exit
  done
) &
sudo_keepalive_pid=$!

cleanup() {
  kill "$sudo_keepalive_pid" 2>/dev/null || true
}
trap cleanup EXIT

brew bundle --file "$brewfile"
