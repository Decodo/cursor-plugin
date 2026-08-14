# Contributing

## Repository layout

```text
.cursor-plugin/marketplace.json     # marketplace manifest, registers each plugin
plugins/decodo/
  .cursor-plugin/plugin.json        # plugin manifest
  assets/logo.svg                   # marketplace logo, 1:1
  rules/install.mdc                 # CLI install + auth recovery
  skills/decodo/SKILL.md            # capability surface
  skills/decodo/references/         # MCP client config, raw HTTP recipes
  README.md                         # setup guide for this plugin
scripts/validate-template.mjs       # manifest validator (from cursor/plugin-template)
```

This is a multi-plugin layout: `marketplace.json` at the repository root registers each plugin,
and every plugin lives in its own folder under `plugins/` with its own `plugin.json`.

Two reasons it is structured this way rather than flat at the root:

- `scripts/validate-template.mjs` only validates a marketplace layout. Without
  `.cursor-plugin/marketplace.json` it exits 0 without checking anything.
- Adding a plugin does not require submitting a different repository URL to Cursor, since the
  submitted URL is this repository.

## Adding a plugin

1. Create `plugins/<name>/.cursor-plugin/plugin.json` with a lowercase kebab-case `name`.
2. Add components — all need YAML frontmatter where applicable:
   - `rules/*.mdc` — `description` required
   - `skills/<skill-name>/SKILL.md` — `name` and `description` required
   - `agents/*.md`, `commands/*.md`
   - `hooks/hooks.json`, `mcp.json` — must use exactly these filenames
3. Commit a 1:1 logo and reference it from `plugin.json` with a relative path.
4. Append an entry to `.cursor-plugin/marketplace.json`:

   ```json
   { "name": "<name>", "source": "./plugins/<name>", "description": "..." }
   ```

5. Validate, then test locally before submitting.

## Validating

```bash
node scripts/validate-template.mjs
```

**Read the output, not just the exit code.** The validator's first action is to read
`.cursor-plugin/marketplace.json`; if that file is missing or unreadable it prints
"Validation passed" and exits 0 without checking a single plugin. A green result with no
per-plugin lines means nothing was validated.

Expected warning for the `decodo` plugin: no `hooks/hooks.json`. That one is intentional — the
plugin ships no hooks. A warning about a missing `mcp.json` means something was deleted; the
plugin ships one.

## Testing locally

Run the installer from the repository root, then restart Cursor:

```bash
bash install.sh              # install (also registers the plugin with Claude Code)
bash install.sh --uninstall  # remove
```

It does the equivalent of this by hand:

```bash
rm -rf ~/.cursor/plugins/local/decodo
cp -R plugins/decodo ~/.cursor/plugins/local/decodo
```

**Do not symlink.** Cursor refuses symlinked local plugins: it enumerates
`~/.cursor/plugins/local/` with `readdir({withFileTypes: true})` and skips every entry
whose `isDirectory()` is false — which is the case for a symlink — then rejects symlinks
again with an explicit check, and its file reader throws on them too. A symlinked plugin
loads nothing and reports no error, so it looks like it worked. Verified against Cursor
3.2.21.

Because this is a copy and not a link, re-run both commands after every edit.

Copy the plugin folder, not the repository root — Cursor expects `.cursor-plugin/plugin.json`
at the top of what you copy.

Confirm the load in the session log rather than trusting the UI:

```bash
LOGS="$HOME/Library/Application Support/Cursor/logs"
grep -rihE "loadUserLocalPlugin|AgentSkillsService load completed" "$LOGS/$(ls -t "$LOGS" | head -1)"
```

A successful load looks like this:

```text
loadUserLocalPlugin decodo loaded in 152.8ms
loadUserLocalPlugins completed in 181.2ms (1 plugins loaded)
CursorPluginsAgentSkillsService load completed {"ruleCount":2,"skillCount":1}
```

`0 plugins loaded` means Cursor did not pick the plugin up, and `skillCount:0` means the
skill is not in context no matter how the agent behaves. Cursor writes a new log directory
per launch, so check that the timestamp belongs to the current session before reading
anything into the counts.

Worth testing (all of it requires a confirmed load first):

- The skill triggers unprompted on a relevant request, without Decodo being named.
- The unauthenticated path works. Use `DECODO_CONFIG_HOME=$(mktemp -d)` to simulate a fresh
  install rather than `decodo reset`, which destroys real credentials.
- A bad token (`DECODO_AUTH_TOKEN=garbage`) causes the agent to follow `install.mdc` recovery
  rather than guess.

**A live MCP server hides the skill.** When Decodo MCP tools are in the tool list, the agent
calls them directly — the skill is never read and the CLI is never invoked. Decodo still gets
used, so "it worked" is a false positive for the skill. This plugin now ships `mcp.json`, and a
user-level Decodo server in `~/.cursor/mcp.json` has the same effect independently.

To test the **skill**, ask for a target outside the enabled toolsets (default `web,search` — so
an Amazon or Reddit request routes to the CLI), or disable the server: Settings → MCP toggle, or
move `~/.cursor/mcp.json` aside, then reload.

To tell the two apart afterwards, grep the current log directory: `mcpToolCall bubble` is MCP, a
terminal command running `decodo` is the skill. Cursor's logs do not record agent terminal
commands, so for a definitive answer read a *copy* of the chat store at
`~/Library/Application Support/Cursor/User/globalStorage/state.vscdb` (SQLite, table
`cursorDiskKV`; `bubbleId:*` rows hold `toolFormerData` with `status` and a base64
`toolCallBinary` containing the shell command). Require `status: completed`, and cross-check any
command string against the repo — the skill's own example commands appear in the store simply
because the skill text entered context.

## Submitting to the marketplace

Submit the repository URL at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish);
the Cursor team reviews before listing. Questions go to `marketplace-publishing@cursor.com`.

The repository must be **public** at submission time. The form also asks for a hosted logotype
URL, which is separate from the in-repo `logo` path in `plugin.json`.
