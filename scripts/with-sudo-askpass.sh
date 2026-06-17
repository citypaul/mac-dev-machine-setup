#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 COMMAND [ARG ...]" >&2
  exit 64
fi

if [[ ! -r /dev/tty ]]; then
  echo "Cannot prompt for sudo password without a terminal" >&2
  exit 1
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/mac-dev-sudo.XXXXXX")"
password_file="$tmp_dir/password"
askpass_file="$tmp_dir/askpass"

cleanup() {
  if [[ -n "${keepalive_pid:-}" ]]; then
    kill "$keepalive_pid" 2>/dev/null || true
  fi
  rm -rf "$tmp_dir"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

chmod 700 "$tmp_dir"

printf "Sudo password: " > /dev/tty
IFS= read -rs sudo_password < /dev/tty
printf "\n" > /dev/tty

printf "%s\n" "$sudo_password" > "$password_file"
unset sudo_password
chmod 600 "$password_file"

printf '#!/usr/bin/env bash\ncat %q\n' "$password_file" > "$askpass_file"
chmod 700 "$askpass_file"

export SUDO_ASKPASS="$askpass_file"
export ANSIBLE_BECOME_PASSWORD_FILE="$askpass_file"
export ANSIBLE_BECOME_ASK_PASS=false

/usr/bin/sudo -A -v

(
  while true; do
    sleep "${SUDO_KEEPALIVE_INTERVAL:-10}"
    /usr/bin/sudo -A -v || exit
  done
) &
keepalive_pid=$!

"$@"
