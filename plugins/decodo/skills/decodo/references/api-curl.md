# Raw HTTP API recipes (curl)

Use this only when neither the `decodo` CLI nor an MCP client is available. Same credential as
everywhere else — a Web Data API **key**, or on older plans a **basic auth token**, from
<https://dashboard.decodo.com/web-data/playground>.

- **API key:** `POST https://data.decodo.com/v1/scrape` with `Authorization: Bearer $DECODO_AUTH_TOKEN`
- **Basic auth token (older plans):** `POST https://scraper-api.decodo.com/v2/scrape` with
  `Authorization: Basic $DECODO_AUTH_TOKEN`
- The examples below use the basic token. For an API key, swap in the host, path and header above.
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
| `geo` | string | Country/geo code, e.g. `us`, `de` |
| `headless` | string | `png` for a screenshot, `html` for rendered HTML |

## Recipes

### Scrape a page as Markdown

```bash
curl -s https://scraper-api.decodo.com/v2/scrape \
  -H "Authorization: Basic $DECODO_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"target":"universal","url":"https://example.com","markdown":true}'
```

### Google SERP, parsed JSON

```bash
curl -s https://scraper-api.decodo.com/v2/scrape \
  -H "Authorization: Basic $DECODO_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"target":"google_search","query":"rust web scraping","parse":true,"geo":"us"}'
```

### Screenshot (PNG, base64 in the response)

```bash
curl -s https://scraper-api.decodo.com/v2/scrape \
  -H "Authorization: Basic $DECODO_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"target":"universal","url":"https://example.com","headless":"png"}'
```

## Response shape

The response is an envelope: `{"results":[{ "content": ..., "status_code": ..., "task_id": ... }], ...}`.
The scraped payload is under `results[0].content` — Markdown text when `markdown:true`, a parsed
object when `parse:true`. Pipe through `jq` and inspect with `jq '.results[0].content | keys'`
first, since parsed structure is target-specific.

Prefer the CLI or MCP when available — they handle retries, output formatting, and exit codes
for you.
