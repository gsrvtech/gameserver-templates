# AthenaBot

## Author & Contributors

| Name   | GitHub Profile               | Buy me a Coffee                                       |
|--------|------------------------------|-------------------------------------------------------|
| gOOvER | https://github.com/gOOvER   | [![donate](https://img.shields.io/badge/Donate-Ko--fi-red)](https://donate.goover.dev) |

---

## About AthenaBot

**AthenaBot** (Lynx Athena Bot) is a feature-rich Discord bot built with Discord.js and Node.js. It runs with a bundled MongoDB instance inside the container, making self-hosting straightforward with no external database required.

---

## Download this Egg

This is a **Pelican** YAML egg (`egg-athena-bot.yaml`).

> **Pterodactyl users:** You can get a Pterodactyl-compatible version in two ways:
> - 🔀 Convert it yourself with **[Scramble Egg Converter](https://redthirten.github.io/scramble-egg-converter/)**
> - 💬 Download a pre-built version via `/egg download` in our **[Discord server](http://discord.gg/raurR4vshX)**

---

## MongoDB

MongoDB runs inside the container. The connection URL is automatically derived from the following egg variables:

| Variable      | Default | Description                                                                                  |
|---------------|---------|----------------------------------------------------------------------------------------------|
| `MONGO_PORT`  | `27017` | Port MongoDB listens on. Change per server instance to run multiple bots on the same node.   |
| `MONGO_DB`    | `botdb` | MongoDB database name.                                                                       |

The resulting URL `mongodb://127.0.0.1:<MONGO_PORT>/<MONGO_DB>` is written to `/home/container/.mongo_url` on every start.

---

## Server Ports

No network port is required for this bot.

---

## Support

Support is provided exclusively via Discord.

[![Join our Discord server!](https://invidget.switchblade.xyz/raurR4vshX)](http://discord.gg/raurR4vshX)

---

## Home Hosting

I cannot and will not provide support for servers hosted at home. 99 % of such issues are caused by incorrect network settings across many different configurations — I simply don't have the time to debug them individually.

---

## Tags

`discord-bot`, `nodejs`, `javascript`, `mongodb`, `discord.js`

---

## License

This Egg is licensed under the [AGPLv3](LICENCE.md) licence.