# Decodo plugins for Cursor

Cursor plugin marketplace repository for [Decodo](https://decodo.com) — web scraping, SERP, and
e-commerce data for AI agents. Decodo handles JavaScript rendering, anti-bot and CAPTCHA, proxy
rotation, and geo-targeting across 125M+ IPs in 195+ locations.

## Plugins

| Plugin | Description |
| --- | --- |
| [`decodo`](plugins/decodo) | Web scraping, SERP, and e-commerce data via the hosted Decodo MCP server and the Decodo CLI |

## Install

Install from the Cursor Marketplace, or point Cursor at this repository directly.

Setup takes one token (`DECODO_AUTH_TOKEN`) and no install step — see
[`plugins/decodo/README.md`](plugins/decodo/README.md).

To try it from a clone before it is listed:

```bash
bash install.sh              # copies plugins/decodo into ~/.cursor/plugins/local/, then restart Cursor
bash install.sh --uninstall  # remove
```

It also registers the plugin with Claude Code, which reads the same skill and commands.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for repository layout and how to add a plugin.

## License

MIT
