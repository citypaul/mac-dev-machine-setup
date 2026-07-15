#!/bin/bash
# Set Fabric's default model without touching provider tokens.

set -euo pipefail

model="${1:-${FABRIC_CODEX_MODEL:-gpt-5.5}}"
vendor="${FABRIC_VENDOR:-Codex}"
env_file="${FABRIC_ENV_FILE:-$HOME/.config/fabric/.env}"

if [ -z "$model" ]; then
  echo "Usage: fabric-set-default-model.sh MODEL" >&2
  exit 1
fi

mkdir -p "$(dirname "$env_file")"
touch "$env_file"
chmod 600 "$env_file"

case "$(printf '%s' "$vendor" | tr '[:upper:]' '[:lower:]')" in
  codex)
    if ! grep -q -E '^CODEX_REFRESH_TOKEN=.+$' "$env_file" ||
      ! grep -q -E '^CODEX_ACCOUNT_ID=.+$' "$env_file"; then
      echo "Codex OAuth is not configured in $env_file." >&2
      echo "Run: make fabric-codex" >&2
      echo "When Fabric setup opens, choose the Codex AI vendor and complete the browser login." >&2
      exit 1
    fi
    ;;
esac

tmp="$(mktemp "${TMPDIR:-/tmp}/fabric-env.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

grep -v -E '^(DEFAULT_VENDOR|DEFAULT_MODEL)=' "$env_file" > "$tmp" || true
{
  printf 'DEFAULT_VENDOR=%s\n' "$vendor"
  printf 'DEFAULT_MODEL=%s\n' "$model"
} >> "$tmp"

install -m 0600 "$tmp" "$env_file"
printf 'Set Fabric default to %s/%s in %s\n' "$vendor" "$model" "$env_file"
