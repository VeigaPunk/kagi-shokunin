#!/usr/bin/env bash
# drift-pins.sh — fingerprint the host files corpus entries cite.
# Cheap staleness gate: run before trusting line refs; a changed sha/linecount
# means re-read that file before citing. Pins dated 2026-09-28 (round 6).
set -euo pipefail
files=(
  "$HOME/.local/bin/the-janitor"
  "$HOME/.config/the-janitor/client.py"
  "$HOME/.config/the-janitor/opencode.json"
  "$HOME/.config/the-janitor/config.json"
  "$HOME/.config/the-janitor/op.env"
  "$HOME/.config/opencode/opencode.json"
  "$HOME/.config/opencode/agents/janitor.md"
  "$HOME/.config/opencode/tools/janitor_auth.ts"
  "$HOME/.config/opencode/plugin/fnm-nudge.js"
  "$HOME/.local/bin/tac-check"
  "$HOME/.local/state/tac/daybreak-blue-access.json"
  "$HOME/.local/state/the-janitor/tac-daybreak-blue.json"
  "$HOME/.local/state/tac/handoff-status.json"
)
for f in "${files[@]}"; do
  if [[ -e "$f" ]]; then
    s=$(stat -c '%a %s' "$f")
    h=$(sha256sum "$f" | cut -c1-16)
    l=$(wc -l < "$f" 2>/dev/null || echo '-')
    printf '%-64s mode+size=%-10s sha16=%s lines=%s\n' "$f" "$s" "$h" "$l"
  else
    printf '%-64s ABSENT\n' "$f"
  fi
done
