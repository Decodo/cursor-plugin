---
name: decodo-setup
description: Get Decodo working in this editor — fetch a token, then authenticate the MCP server, the CLI, or both.
argument-hint: "[mcp|cli] (optional — otherwise ask)"
---

# Set up Decodo

Get the user from nothing to a working Decodo surface. Do not scrape anything in this command.

## 1. Find out what already works

Run both checks before asking the user for anything:

```bash
decodo whoami 2>&1 || npx -y @decodo/cli whoami 2>&1
```

And look at your own tool list for Decodo MCP tools (`scrape_as_markdown`, `google_search`, …).

Report the result as a two-line status, then continue only for the parts that are missing:

- **MCP**: tools present / absent
- **CLI**: exit 0 (a token is configured — not necessarily a valid one) / exit 3 (no token) /
  `command not found`

## 2. Get a token (needed for either lane)

Both lanes use the same Web Data API key. Older plans only have a basic auth token, which works the same way. Point the user at
<https://dashboard.decodo.com/web-data/playground> — a free account gives ~2K requests with no card.

**Never read, `cat`, echo, or log the token**, and never write it into a file the user tracks in
git. If a token is already configured somewhere, do not extract it to reuse it elsewhere — ask
for it.

## 3. Authenticate the lane the user wants

If `$ARGUMENTS` names a lane, do that one. Otherwise ask which they want — and if an ask-user
tool is available (such as `AskUserQuestion`), use it:

**"How do you want to use Decodo?"**

1. **MCP server (Recommended — no install)** — tool calls, nothing to install
2. **CLI** — full target surface, needs a shell
3. **Both**

### MCP

The MCP server is declared in this plugin's `mcp.json`; it needs the token as a plugin variable.
This is a UI step you cannot do for the user — tell them:

> Cursor → Settings → Plugins → Decodo → set **DECODO_AUTH_TOKEN** to your token, then reload
> the window.

Optionally also set **DECODO_TOOLSETS** (default `web,search`; available `web`, `search`,
`ecommerce`, `social_media`, `ai`). Every enabled tool's schema is resident in every request, so
widen it only when the user actually needs those targets — the CLI covers all of them without
the context cost.

`DECODO_AUTH_TOKEN` in the environment also resolves, and takes precedence over the plugin
variable. That is the fallback if the Settings UI is unavailable.

Confirm by reloading and checking that Decodo tools appear in the tool list.

### CLI

```bash
export DECODO_AUTH_TOKEN='<token>'     # session-scoped, no interaction
decodo setup --token '<token>'         # persist to config, validates against the API
```

Never run a bare `decodo setup` — it opens an interactive prompt you cannot drive.

Not installed? `npx -y @decodo/cli <command>` needs no install. For a persistent command:

```bash
curl -fsSL https://decodo.github.io/cli/install.sh | sh   # macOS / Linux
irm https://decodo.github.io/cli/install.ps1 | iex        # Windows PowerShell
npm install -g @decodo/cli                                # any platform
```

If install or `PATH` fails, follow the `install.mdc` rule in this plugin — do not improvise, and
never suggest `sudo npm install -g`.

## 4. Prove it works

`decodo whoami` exits **0** on a token the API would reject — it reads local config and makes no
network call, so it never proves auth. Validate with a real call:

```bash
decodo setup --token '<token>'     # verifies against the API, writes nothing on failure
# or a cheap live request:
decodo scrape https://example.com
```

For MCP, one `scrape_as_markdown` call on `https://example.com` is the equivalent.

Then tell the user which lane is live and stop. Do not chain into the task they mentioned
earlier unless they asked you to.
