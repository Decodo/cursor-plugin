#!/usr/bin/env bash
# install.sh — install the Decodo plugin locally for development/testing
#
# Usage:
#   bash install.sh              # install
#   bash install.sh --uninstall  # remove
#
# Copies plugins/decodo to ~/.cursor/plugins/local/decodo/ and registers it in
# ~/.claude/ so both Cursor and Claude Code pick it up on next start.
#
# This is a COPY, not a symlink: Cursor refuses symlinked local plugins and
# reports no error when it skips them (verified against Cursor 3.2.21), so a
# symlinked plugin looks installed and loads nothing. Re-run after every edit.

set -euo pipefail

PLUGIN_NAME="decodo"
PLUGIN_ID="${PLUGIN_NAME}@local"
PLUGIN_DIR="${HOME}/.cursor/plugins/local/${PLUGIN_NAME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/plugins/${PLUGIN_NAME}"

CLAUDE_DIR="${HOME}/.claude"
CLAUDE_PLUGINS="${CLAUDE_DIR}/plugins/installed_plugins.json"
CLAUDE_SETTINGS="${CLAUDE_DIR}/settings.json"

COMPONENTS=(
  ".cursor-plugin"
  "skills"
  "commands"
  "rules"
  "assets"
  "mcp.json"
)

# Upsert a plugin entry into a JSON file without clobbering other plugins.
# Requires python3 (ships with macOS and most Linux).
json_upsert() {
  local file="$1" script="$2"
  command -v python3 >/dev/null 2>&1 || { echo "  ⚠ python3 not found — skipping ${file}"; return; }
  mkdir -p "$(dirname "$file")"
  python3 -c "$script"
}

uninstall() {
  if [ -d "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
    echo "Removed ${PLUGIN_DIR}"
  else
    echo "Plugin not found at ${PLUGIN_DIR} — nothing to remove."
  fi

  json_upsert "$CLAUDE_PLUGINS" "
import json, os, sys
path = '$CLAUDE_PLUGINS'
if not os.path.exists(path): sys.exit(0)
try: data = json.load(open(path))
except Exception: sys.exit(0)
plugins = data.get('plugins', {})
plugins.pop('$PLUGIN_ID', None)
data['plugins'] = plugins
json.dump(data, open(path, 'w'), indent=2)
"
  json_upsert "$CLAUDE_SETTINGS" "
import json, os, sys
path = '$CLAUDE_SETTINGS'
if not os.path.exists(path): sys.exit(0)
try: data = json.load(open(path))
except Exception: sys.exit(0)
data.get('enabledPlugins', {}).pop('$PLUGIN_ID', None)
json.dump(data, open(path, 'w'), indent=2)
"

  echo "Restart Cursor to apply."
}

install() {
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: ${SOURCE_DIR} not found. Run this from a clone of Decodo/cursor-plugin." >&2
    exit 1
  fi

  # 1. Copy plugin files (real directory — see the symlink note above)
  [ -d "$PLUGIN_DIR" ] && rm -rf "$PLUGIN_DIR"
  mkdir -p "$PLUGIN_DIR"

  for component in "${COMPONENTS[@]}"; do
    src="${SOURCE_DIR}/${component}"
    [ -e "$src" ] && cp -R "$src" "$PLUGIN_DIR/${component}"
  done
  echo "Copied plugin to ${PLUGIN_DIR}"

  # 2. Register in ~/.claude/plugins/installed_plugins.json
  json_upsert "$CLAUDE_PLUGINS" "
import json, os
path = '$CLAUDE_PLUGINS'
data = {}
if os.path.exists(path):
    try: data = json.load(open(path))
    except Exception: data = {}
plugins = data.get('plugins', {})
entries = [e for e in plugins.get('$PLUGIN_ID', [])
           if not (isinstance(e, dict) and e.get('scope') == 'user')]
entries.insert(0, {'scope': 'user', 'installPath': '$PLUGIN_DIR'})
plugins['$PLUGIN_ID'] = entries
data['plugins'] = plugins
os.makedirs(os.path.dirname(path), exist_ok=True)
json.dump(data, open(path, 'w'), indent=2)
"

  # 3. Enable in ~/.claude/settings.json
  json_upsert "$CLAUDE_SETTINGS" "
import json, os
path = '$CLAUDE_SETTINGS'
data = {}
if os.path.exists(path):
    try: data = json.load(open(path))
    except Exception: data = {}
data.setdefault('enabledPlugins', {})['$PLUGIN_ID'] = True
os.makedirs(os.path.dirname(path), exist_ok=True)
json.dump(data, open(path, 'w'), indent=2)
"

  echo ""
  echo "Installed. Next steps:"
  echo "  1. Restart Cursor (or Cmd/Ctrl+Shift+P → Developer: Reload Window)"
  echo "  2. Set DECODO_AUTH_TOKEN — Settings → Plugins → Decodo, or export it in your shell"
  echo "  3. Confirm the load (the Plugins UI is not a reliable signal):"
  echo "     LOGS=\"\$HOME/Library/Application Support/Cursor/logs\""
  echo "     grep -ri loadUserLocalPlugin \"\$LOGS/\$(ls -t \"\$LOGS\" | head -1)\""
  echo ""
  echo "  Note: with the MCP server configured, plain scrape/search requests go through MCP"
  echo "  tools, not the CLI skill. To exercise the skill, leave DECODO_TOOLSETS unset and ask"
  echo "  for a target outside web,search (e.g. an Amazon product), or disable the server."
}

case "${1:-}" in
  --uninstall) uninstall ;;
  *)           install ;;
esac
