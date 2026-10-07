---
name: decodo-status
description: Report which Decodo surfaces are live in this session — MCP tools, CLI version and auth, enabled toolsets — without scraping anything.
---

# Decodo status

Diagnose, do not fix. Report what is true, then name the single next step if something is off.

## MCP lane

Check your own tool list for Decodo tools. Report:

- **Tools present?** yes / no
- **Which ones**, and therefore which toolsets are enabled (`scrape_as_markdown`/`screenshot` →
  `web`; `google_search`/`bing_search` → `search`; `amazon_*`/`walmart_*`/`target_*` →
  `ecommerce`; `reddit_*`/`tiktok_*`/`youtube_*` → `social_media`; `chatgpt`/`perplexity`/
  `google_ai_mode` → `ai`).

Do not call a tool just to test it — that bills a request. Presence in the tool list is the
check.

**Connected does not mean authenticated.** The server accepts `initialize` and `tools/list` with
any `Authorization` header, valid or not, so Cursor shows the server connected with its full tool
list even when the token is wrong or missing entirely. If `DECODO_AUTH_TOKEN` is unset, the
header is sent as the literal `${DECODO_AUTH_TOKEN}` and the connection still succeeds — then
every tool call fails with:

```
Scraper API request failed (401): Authentication failed.
```

So report the MCP lane as "connected — token unverified", and if the user has seen that 401,
treat it as an unset or wrong `DECODO_AUTH_TOKEN`, not as a Decodo outage. Verified Aug 2026.

## CLI lane

```bash
decodo --version 2>&1 || npx -y @decodo/cli --version 2>&1
decodo whoami 2>&1
```

Report version and auth source. Two things to state plainly rather than paper over:

- **`whoami` does not validate.** It reads local config, makes no network call, and exits 0 on a
  token the API would reject. Report it as "a token is configured", never as "authenticated".
- **Version below 1.0.0** → flag it. 0.x stored config in a different directory and has no
  migration, so an upgrade looks like lost auth.

Exit 3 means no usable token (`No API key or auth token found.`) or a rejected one (`Username invalid.` —
the wording says "Username" because the token is basic-auth credentials).

## Report

Give the user a short table — surface, state, next step — and nothing else:

| Surface | State |
|---|---|
| MCP | tools present, toolsets `web,search` |
| CLI | v1.0.2, token configured (unvalidated) |

If both lanes are live, say so and note that plain scrape/search will go through MCP while
everything else goes through the CLI. If neither is, point at `/decodo-setup`.

Never print, echo, or partially reveal the token, even masked output copied from `whoami`.
