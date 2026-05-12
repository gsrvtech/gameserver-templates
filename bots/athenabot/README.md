# AthenaBot

## Author & Contributors
| Name | GitHub Profile | Buy me a Coffee |
|------|----------------|-----------------|
| gOOvER | https://github.com/gOOvER | [![donate](https://donate.goover.dev)](https://donate.goover.dev) |

## AthenaBot

## MongoDB

MongoDB runs inside the container. The connection URL is automatically derived from the following egg variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGO_PORT` | `27017` | Port MongoDB listens on. Change per server instance to run multiple bots on the same node. |
| `MONGO_DB` | `botdb` | MongoDB database name. |

The resulting URL `mongodb://127.0.0.1:<MONGO_PORT>/<MONGO_DB>` is written to `/home/container/.mongo_url` on every start.

## Pterodactyl Egg

> **Note:** Pterodactyl (`.json`) eggs are no longer maintained in this repository.  
> Use the Pelican YAML egg (`egg-athena-bot.yaml`) and convert it with **[Scramble Egg Converter](https://redthirten.github.io/scramble-egg-converter/)** to get a Pterodactyl-compatible JSON egg.

## Server Ports

| Port | Default |
|------|---------|
| | |

No port needed.