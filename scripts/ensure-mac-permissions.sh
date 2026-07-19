#!/usr/bin/env bash
# Pre-flight: make sure the terminal running this setup has the macOS
# permissions Homebrew needs to upgrade GUI apps.
#
# macOS TCC permissions cannot be granted programmatically without MDM
# enrollment -- that is by design, so malware can't self-grant. What CAN
# be automated: detecting what's missing, clearing any recorded denial,
# triggering the system prompt, opening the exact Settings pane, and
# waiting for the one-time grant. After that, every run passes straight
# through with no interaction.
#
#   App Management -> lets Homebrew replace app bundles in /Applications
#                     and strip their quarantine attribute
#   Automation     -> lets Homebrew quit running apps before upgrading them
set -euo pipefail

PROBE_ATTR="dev.macsetup.tcc-probe"
WAIT_SECS=180

terminal_app() {
  local pid=$$ comm
  while [[ "$pid" -gt 1 ]]; do
    comm=$(ps -o comm= -p "$pid" 2>/dev/null) || return 1
    if [[ "$comm" == *".app/Contents/MacOS/"* ]]; then
      printf '%s\n' "${comm%%.app/Contents/MacOS/*}.app"
      return 0
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ') || return 1
    [[ -n "$pid" ]] || return 1
  done
  return 1
}

# Writing an xattr on another app's bundle root is gated by App Management,
# so a harmless write-then-delete probe tells us whether it is granted.
probe_app_management() {
  local app candidates=0
  for app in /Applications/*.app; do
    [[ "$app" == "${TERMINAL_APP:-}" ]] && continue
    [[ -O "$app" ]] || continue
    candidates=$((candidates + 1))
    if /usr/bin/xattr -w "$PROBE_ATTR" 1 "$app" 2>/dev/null; then
      /usr/bin/xattr -d "$PROBE_ATTR" "$app" 2>/dev/null || true
      return 0
    fi
    [[ "$candidates" -ge 3 ]] && return 1
  done
  # No user-owned apps to probe means nothing Homebrew could upgrade anyway.
  [[ "$candidates" -eq 0 ]]
}

probe_automation() {
  osascript -e 'tell application id "com.apple.systemevents" to count processes' >/dev/null 2>&1
}

wait_for() { # wait_for <probe-fn> <label>
  local fn=$1 label=$2 waited=0
  until "$fn"; do
    if [[ "$waited" -ge "$WAIT_SECS" ]]; then
      echo "Timed out waiting for the $label permission." >&2
      echo "If you already enabled it, quit and reopen your terminal, then re-run." >&2
      return 1
    fi
    if [[ "$waited" -eq 0 ]]; then
      echo "  Waiting for you to grant $label (up to ${WAIT_SECS}s)..."
    fi
    sleep 3
    waited=$((waited + 3))
  done
}

TERMINAL_APP=$(terminal_app || true)
BUNDLE_ID=""
if [[ -n "$TERMINAL_APP" ]]; then
  BUNDLE_ID=$(mdls -raw -name kMDItemCFBundleIdentifier "$TERMINAL_APP" 2>/dev/null || true)
  [[ "$BUNDLE_ID" == "(null)" ]] && BUNDLE_ID=""
fi
TERMINAL_NAME=${TERMINAL_APP:+$(basename "$TERMINAL_APP" .app)}
TERMINAL_NAME=${TERMINAL_NAME:-your terminal}

if probe_app_management; then
  echo "✓ App Management permission: granted"
else
  echo "✗ App Management permission missing for $TERMINAL_NAME."
  echo "  Without it Homebrew cannot replace apps in /Applications."
  if [[ -n "$BUNDLE_ID" ]]; then
    tccutil reset AppManagement "$BUNDLE_ID" >/dev/null 2>&1 || true
  fi
  probe_app_management >/dev/null 2>&1 || true # may now trigger the system prompt
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_AppManagement"
  echo "  Enable $TERMINAL_NAME in the App Management pane that just opened"
  echo "  (or click Allow on the system prompt if one appeared)."
  wait_for probe_app_management "App Management"
  echo "✓ App Management permission: granted"
fi

if probe_automation; then
  echo "✓ Automation (System Events) permission: granted"
else
  echo "✗ Automation permission missing for $TERMINAL_NAME."
  echo "  Without it Homebrew cannot quit running apps before upgrading them."
  if [[ -n "$BUNDLE_ID" ]]; then
    tccutil reset AppleEvents "$BUNDLE_ID" >/dev/null 2>&1 || true
  fi
  echo "  Click OK on the system prompt..."
  if ! probe_automation; then
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
    echo "  Enable System Events under $TERMINAL_NAME in the Automation pane that just opened."
    wait_for probe_automation "Automation (System Events)"
  fi
  echo "✓ Automation (System Events) permission: granted"
fi
