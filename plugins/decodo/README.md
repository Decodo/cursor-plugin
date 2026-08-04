# Decodo for Cursor

Web scraping, SERP, and e-commerce data for AI agents. Decodo handles JavaScript rendering,
anti-bot/CAPTCHA, proxy rotation, and geo-targeting (125M+ IPs, 195+ locations) so the agent
gets clean data instead of a 403.

## What the agent can do

- **Scrape any page** as clean markdown, including JS-heavy and geo-restricted pages
- **Search** Google or Bing and get parsed SERP JSON
- **E-commerce data** from Amazon, Walmart, and Target (product, search, pricing, sellers)
- **Social data** from Reddit, TikTok, and YouTube
- **Screenshots** of fully rendered pages

## Setup

You need a Web Scraping API basic auth token from the
[Decodo Playground](https://dashboard.decodo.com/playground). A free account covers up to
2,000 requests with no card.

```bash
export DECODO_AUTH_TOKEN='<your-token>'
```

No install is required — the agent can run everything through `npx -y @decodo/cli`. For a
persistent command:

```bash
curl -fsSL https://decodo.github.io/cli/install.sh | sh   # macOS / Linux
npm install -g @decodo/cli                                # any platform
```

Then persist the token to the CLI config:

```bash
decodo setup --token '<your-token>'
decodo whoami        # verify
```

## Try it

Ask the agent things like:

- "Scrape decodo.com and summarise the homepage."
- "What are the top 5 Google results for *web scraping api*?"
- "Get the price and rating for Amazon ASIN B09H74FXNW."
- "Pull the top posts from r/webscraping this week."

## Contents

| Component | Purpose |
| --- | --- |
| `skills/decodo/SKILL.md` | When to reach for Decodo, CLI usage, output handling, exit codes |
| `skills/decodo/references/` | MCP client config and raw HTTP API recipes |
| `rules/install.mdc` | Install, PATH, and authentication failure recovery |

## Links

- CLI: <https://github.com/Decodo/cli> · [`@decodo/cli`](https://www.npmjs.com/package/@decodo/cli)
- MCP server: <https://github.com/Decodo/mcp-server> · hosted at `https://mcp.decodo.com/mcp`
- Docs: <https://help.decodo.com>

## License

MIT
