# Decodo plugins for Cursor

Cursor plugin marketplace repository for [Decodo](https://decodo.com) — web scraping, SERP,
and e-commerce data for AI agents.

## Plugins

| Plugin | Description |
| --- | --- |
| [`decodo`](plugins/decodo) | Web scraping, SERP, and e-commerce data via the Decodo CLI |

## Install

Install from the Cursor Marketplace, or point Cursor at this repository directly.

You will need a Web Scraping API basic auth token from the
[Decodo Playground](https://dashboard.decodo.com/playground) — free accounts include up to
2,000 requests with no card. See [`plugins/decodo/README.md`](plugins/decodo/README.md) for
setup.

## Repository layout

```text
.cursor-plugin/marketplace.json     # marketplace manifest, registers each plugin
plugins/decodo/
  .cursor-plugin/plugin.json        # plugin manifest
  rules/install.mdc                 # CLI install + auth recovery
  skills/decodo/SKILL.md            # capability surface
  skills/decodo/references/         # MCP config, raw HTTP recipes
  assets/logo.svg                   # marketplace logo
scripts/validate-template.mjs       # manifest validator (from cursor/plugin-template)
```

## Adding a plugin

1. Create `plugins/<name>/.cursor-plugin/plugin.json` with a lowercase kebab-case `name`.
2. Add components: `rules/*.mdc`, `skills/<skill>/SKILL.md`, `agents/*.md`,
   `commands/*.md`, `hooks/hooks.json`, `mcp.json` — all need YAML frontmatter where
   applicable.
3. Append an entry to `.cursor-plugin/marketplace.json` with `name`, `source`, `description`.
4. Validate:

   ```bash
   node scripts/validate-template.mjs
   ```

   Read the output, not just the exit code — the validator exits 0 without checking anything
   if it cannot find `.cursor-plugin/marketplace.json`.

## License

MIT
