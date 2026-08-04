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

Expected warnings for the `decodo` plugin: no `hooks/hooks.json` and no `mcp.json`. Both are
intentional — the plugin is CLI-backed and ships neither.

## Testing locally

Symlink the plugin into Cursor's local plugin directory and restart Cursor:

```bash
ln -s "$PWD/plugins/decodo" ~/.cursor/plugins/local/decodo
```

Point the symlink at the plugin folder, not the repository root — Cursor expects
`.cursor-plugin/plugin.json` at the top of what you link. Remove it with
`rm ~/.cursor/plugins/local/decodo`.

Local plugins do not always appear under Settings → Plugins even when they load, so treat
agent behaviour as the real signal.

Worth testing:

- The skill triggers unprompted on a relevant request, without Decodo being named.
- The unauthenticated path works. Use `DECODO_CONFIG_HOME=$(mktemp -d)` to simulate a fresh
  install rather than `decodo reset`, which destroys real credentials.
- A bad token (`DECODO_AUTH_TOKEN=garbage`) causes the agent to follow `install.mdc` recovery
  rather than guess.

## Submitting to the marketplace

Submit the repository URL at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish);
the Cursor team reviews before listing. Questions go to `marketplace-publishing@cursor.com`.

The repository must be **public** at submission time. The form also asks for a hosted logotype
URL, which is separate from the in-repo `logo` path in `plugin.json`.
