# Raw HTTP API recipes (curl)

Use this only when neither the `decodo` CLI nor an MCP client is available. Same credential as
everywhere else — a Web Data API **key**, or on older plans a **basic auth token**, from
<https://dashboard.decodo.com/web-data/playground>.

- **Endpoint (sync):** `POST https://data.decodo.com/v1/scrape`
- **Auth header:** `Authorization: Bearer $DECODO_AUTH_TOKEN`
- **Older plans (basic auth token):** see [Basic auth token](#basic-auth-token-older-plans) below.
- **Body:** JSON; `target` selects what to scrape, plus per-target params.

## Target names

The API uses **snake_case** target values (`universal`, `google_search`, `amazon_product`,
`bing_search`, `reddit_post`, …) — the CLI's kebab-case names (`google-search`) map directly to
these. Full list and per-target params: <https://help.decodo.com/docs/web-scraping-api-targets>
and <https://help.decodo.com/docs/web-scraping-api-parameters>.

## Common parameters

| Param | Type | Notes |
| --- | --- | --- |
| `target` | string | Required. e.g. `universal`, `google_search`, `amazon_product` |
| `url` | string | For URL targets (`universal`, `amazon_product` by URL, …) |
| `query` | string | For search targets (`google_search`, `bing_search`, …) |
| `markdown` | bool | Return page content as Markdown |
| `parse` | bool | Return structured JSON (parse-enabled targets only) |
| `geo` | string | Country/geo code, e.g. `US`, `DE` |
| `headless` | string | `png` for a screenshot, `html` for rendered HTML |

## Recipes

### Scrape a page as Markdown

```bash
curl -s https://data.decodo.com/v1/scrape \
  -H "Authorization: Bearer $DECODO_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "x-integration: cursor-plugin" \
  -d '{"target":"universal","url":"https://example.com","markdown":true}'
```

### Google SERP, parsed JSON

```bash
curl -s https://data.decodo.com/v1/scrape \
  -H "Authorization: Bearer $DECODO_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "x-integration: cursor-plugin" \
  -d '{"target":"google_search","query":"rust web scraping","parse":true,"geo":"US"}'
```

### Screenshot (PNG, base64 in the response)

```bash
curl -s https://data.decodo.com/v1/scrape \
  -H "Authorization: Bearer $DECODO_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -H "x-integration: cursor-plugin" \
  -d '{"target":"universal","url":"https://example.com","headless":"png"}'
```

## Search, map and crawl (Data API)

These endpoints sit on the same host and need an API key; a basic auth token is rejected.

```bash
H=(-H "Authorization: Bearer $DECODO_AUTH_TOKEN" -H "Content-Type: application/json" -H "x-integration: cursor-plugin")

# Web search → parsed JSON with .organic[]
curl -s https://data.decodo.com/v1/search "${H[@]}" -d '{"query":"rust web scraping","geo":"DE"}'

# Map → .results[].content.links[].url
curl -s https://data.decodo.com/v1/map "${H[@]}" \
  -d '{"url":"https://example.com","limit":100,"select_paths":["/blog/*"]}'

# Crawl: start (returns crawl_id), poll status, then page through results with `next`
curl -s https://data.decodo.com/v1/crawl "${H[@]}" -d '{"url":"https://example.com","limit":50}'
curl -s https://data.decodo.com/v1/crawl/<crawl_id>/status "${H[@]}"
curl -s "https://data.decodo.com/v1/crawl/<crawl_id>?type=content" "${H[@]}" -o pages.json  # omit ?type=content for metadata only
curl -s -X POST https://data.decodo.com/v1/crawl/<crawl_id>/cancel "${H[@]}"
```

Write crawl pages to a file and read them with `jq`, never straight into context.

## Basic auth token (older plans)

Same bodies and response shape for `/scrape`; only the host, path and header change. There is
no search, map or crawl on this host — those need an API key.

```bash
curl -s https://scraper-api.decodo.com/v2/scrape \
  -H "Authorization: Basic $DECODO_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"target":"universal","url":"https://example.com","markdown":true}'
```

A credential sent to the other host is rejected: a key on `/v2/scrape` returns `Username invalid.`,
a token on `data.decodo.com` returns `Invalid credentials`.

## Response shape

The response is an envelope: `{"results":[{ "content": ..., "status_code": ..., "task_id": ... }], ...}`.
The scraped payload is under `results[0].content` — Markdown text when `markdown:true`, a parsed
object when `parse:true`. Pipe through `jq` and inspect with `jq '.results[0].content | keys'`
first, since parsed structure is target-specific.

Prefer the CLI or MCP when available — they handle retries, output formatting, and exit codes
for you.
