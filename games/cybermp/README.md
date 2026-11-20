# CyberMP (Cyberpunk 2077)

## Author & Contributors

| Name   | GitHub Profile               | Buy me a Coffee                                       |
|--------|------------------------------|-------------------------------------------------------|
| gOOvER | https://github.com/gOOvER   | [![donate](https://img.shields.io/badge/Donate-Ko--fi-red)](https://donate.goover.dev) |

---

## About CyberMP

**[CyberMP](https://cyber.mp/)** is a multiplayer mod for **Cyberpunk 2077** with dedicated servers and a resource scripting API.

The egg downloads the Linux server build from [CyberMP-Server-Releases](https://github.com/Cyber-MP/CyberMP-Server-Releases/releases) and runs it on `ghcr.io/goover/debian:13-trixie`. Required shared libraries (`libssl1.1`, `nng`, `c-ares`, `libcurl-gnutls`) are bundled into `./libs` during installation.

- **Documentation:** [docs.cyber.mp](https://docs.cyber.mp)

---

## Download this Egg

This is a **Pelican** YAML egg (`egg-cyber-m-p.yaml`).

> **Pterodactyl users:** You can get a Pterodactyl-compatible version in two ways:
> - 🔀 Convert it yourself with **[Scramble Egg Converter](https://redthirten.github.io/scramble-egg-converter/)**
> - 💬 Download a pre-built version via `/egg download` in our **[Discord server](http://discord.gg/raurR4vshX)**

---

## Server Ports

TCP and UDP use the same port.

| Port       | Default | Description               |
|------------|---------|---------------------------|
| Game Port  | 2077    | Main game connection port |

---

## Variables

| Variable | Default | Description |
| --- | --- | --- |
| `SERVER_VERSION` | `latest` | Release tag such as `v4.0.4-beta.1`, or `latest`. Reinstall to apply. |
| `PUBLIC_ADDRESS` | empty | Public IP/hostname clients connect to (`connection_host_addr`). Required for the server list. |
| `CYBERMP_MAX_PLAYERS` | `20` | Maximum player slots. |
| `CYBERMP_PRIVATE_TOKEN` | empty | Masterlist token. Leave empty for private servers. |
| `CYBERMP_DISABLE_VOICE` | `false` | Disable the built-in VoIP server. |
| `CYBERMP_EP2_DLC_ENABLED` | `false` | Enable Phantom Liberty content. |

Other settings, including the `resources` list, are configured in `server.toml`. It is kept across reinstalls.

---

## Support

Support is provided exclusively via Discord.

[![Join our Discord server!](https://invidget.switchblade.xyz/raurR4vshX)](http://discord.gg/raurR4vshX)

---

## License

This Egg is licensed under the [AGPLv3](LICENCE.md) licence.
