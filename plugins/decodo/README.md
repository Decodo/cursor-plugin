# Decodo for Cursor

Give Cursor's agent real web access. Decodo handles JavaScript rendering, anti-bot and CAPTCHA,
proxy rotation, and geo-targeting across 125M+ IPs in 195+ locations — so the agent gets clean
data instead of a 403.

## What this plugin adds

| Component | What it does |
| --- | --- |
| `decodo` skill | Teaches the agent when to reach for Decodo, which target to pick, and how to handle output |
| MCP server | Hosted Decodo tools the agent can call directly — no install, no shell |
| `/decodo-setup`, `/decodo-status` | Get a token in place; see which surfaces are live |
| `install` rule | Recovers from install, `PATH`, and authentication failures without you debugging them |

## Two surfaces, one token

| | MCP server | `decodo` CLI |
| --- | --- | --- |
| Install | none | none (`npx`) or one installer command |
| Needs a shell | no | yes |
| Coverage | the toolsets you enable | every target, always |
| Best for | plain scrape and search | retail, social, screenshots to file, batches, `jq` |

Both ship enabled. The skill routes plain scrape/search through MCP and everything else through
the CLI, so you don't have to think about it.

The MCP server defaults to the `web,search` toolsets. Widen it with `DECODO_TOOLSETS` (`web`,
`search`, `ecommerce`, `social_media`, `ai`) only if you want those targets as direct tool calls
— every enabled tool costs context in every request, and the CLI already covers all of them.

## Setup

**1. Get a token.** Grab a Web Scraping API basic auth token from the
[Decodo Playground](https://dashboard.decodo.com/playground). A free account includes 2,000
requests, no card required.

**2. Set `DECODO_AUTH_TOKEN`.** Cursor prompts for it when you install the plugin, or set it
later under Settings → Plugins → Decodo. That one value authenticates the MCP server and the
CLI. An exported shell variable also works and takes precedence:

```bash
export DECODO_AUTH_TOKEN='<your-token>'     # session-scoped
npx -y @decodo/cli setup --token '<token>'  # CLI only, saved to ~/.config/decodo
```

Or just run `/decodo-setup` and let the agent walk you through it.

That's it. **No install step** — MCP is hosted, and the CLI runs via `npx -y @decodo/cli` on
demand.

For a persistent `decodo` command in your own terminal:

```bash
curl -fsSL https://decodo.github.io/cli/install.sh | sh   # macOS / Linux
irm https://decodo.github.io/cli/install.ps1 | iex        # Windows
```

Use the installer rather than `npm install -g` — it falls back to a user-writable prefix
automatically on machines where the npm global directory needs sudo.

Verify with `decodo whoami`.

## What it supports

**Any URL**, returned as clean markdown — including pages that need JavaScript to render, are
geo-restricted, rate-limited, or sitting behind anti-bot protection. Requests can be
geo-targeted by country.

**Dedicated targets** for major search engines, retailers, social platforms, and AI tools —
including Google, Bing, Amazon, Walmart, Target, Reddit, YouTube, and TikTok — return parsed,
structured JSON instead of raw HTML. That is both more reliable and far cheaper on context than
parsing a page yourself.

Targets are generated from the Decodo API schema at runtime, so new ones become available
without updating this plugin. To see what's currently available:

```bash
decodo targets                  # every target, grouped by category
decodo amazon-product --help    # exact flags for a given target
```

The skill instructs the agent to check `decodo targets` and prefer a dedicated target over a
generic scrape whenever one exists.

## Try it

Ask the agent, in plain language:

- "What are the top 5 Google results for *web scraping api*?"
- "Scrape decodo.com and summarise what they sell."
- "Get the price and rating for Amazon ASIN B09H74FXNW."
- "What are people saying about web scraping in r/webscraping this week?"

## Output

Markdown for pages, parsed JSON for targets that support `--parse`, and NDJSON for streaming
into `jq`. The skill instructs the agent to select only the fields it needs, so large pages
don't flood your context.

## Troubleshooting

Run `/decodo-status` first — it reports which surfaces are actually live. Authentication and
install problems are handled by the bundled `install` rule, so ask the agent and it will work
through them. Common cases:

| Symptom | Cause |
| --- | --- |
| Server shows connected, but every call returns `Scraper API request failed (401)` | `DECODO_AUTH_TOKEN` is unset or wrong. The server accepts any `Authorization` header at connect time, so the tool list appears either way — connected is not authenticated |
| No Decodo tools in the tool list | The window needs reloading, or the plugin didn't load |
| MCP works, but no Amazon/Reddit tools | Those live in the `ecommerce`/`social_media` toolsets — the CLI covers them without widening `DECODO_TOOLSETS` |
| `No auth token found.` after upgrading from CLI 0.x | Config location changed; the rule migrates it |
| `EACCES` on `npm install -g` | Use the `curl` installer instead |
| Old version after upgrading | Two installs on `PATH`; `where decodo` to find both |

`decodo whoami` reads local config and makes no network call — it exits 0 on a token the API
would reject, so treat it as "a token is configured", not "authentication works".

## Links

- CLI: [Decodo/cli](https://github.com/Decodo/cli) · [`@decodo/cli`](https://www.npmjs.com/package/@decodo/cli)
- MCP server: [Decodo/mcp-server](https://github.com/Decodo/mcp-server) · hosted at `https://mcp.decodo.com/mcp`
- Docs: [help.decodo.com](https://help.decodo.com)

## License

MIT
