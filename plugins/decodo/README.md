# Decodo for Cursor

Give Cursor's agent real web access. Decodo handles JavaScript rendering, anti-bot and CAPTCHA,
proxy rotation, and geo-targeting across 125M+ IPs in 195+ locations — so the agent gets clean
data instead of a 403.

## What this plugin adds

| Component | What it does |
| --- | --- |
| `decodo` skill | Teaches the agent when to reach for Decodo, which target to pick, and how to handle output |
| `install` rule | Recovers from install, `PATH`, and authentication failures without you debugging them |

The agent calls the Decodo CLI as a subprocess. No MCP server to configure.

## Setup

**1. Get a token.** Grab a Web Scraping API basic auth token from the
[Decodo Playground](https://dashboard.decodo.com/playground). A free account includes 2,000
requests, no card required.

**2. Make it available.** Either is fine:

```bash
export DECODO_AUTH_TOKEN='<your-token>'     # session-scoped
npx -y @decodo/cli setup --token '<token>'  # saved to ~/.config/decodo
```

That's it. **No install step** — the agent runs `npx -y @decodo/cli` on demand.

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

Authentication and install problems are handled by the bundled `install` rule — ask the agent
and it will work through them. Common cases:

| Symptom | Cause |
| --- | --- |
| `No auth token found.` after upgrading from CLI 0.x | Config location changed; the rule migrates it |
| `EACCES` on `npm install -g` | Use the `curl` installer instead |
| Old version after upgrading | Two installs on `PATH`; `where decodo` to find both |

## Links

- CLI: [Decodo/cli](https://github.com/Decodo/cli) · [`@decodo/cli`](https://www.npmjs.com/package/@decodo/cli)
- MCP server (for clients without a shell): [Decodo/mcp-server](https://github.com/Decodo/mcp-server)
- Docs: [help.decodo.com](https://help.decodo.com)

## License

MIT
