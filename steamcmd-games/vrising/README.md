<div align="center">

  # V Rising (BepInEx)

  **Windows-native V Rising Dedicated Server running on Wine with automatic BepInEx (IL2CPP) support for Pelican Panel.**

  [![Pelican](https://img.shields.io/badge/Panel-Pelican%20(PLCN__v3)-0066ff?style=flat-square)](egg-v-rising-bep-in-ex.yaml)
  [![Runtime](https://img.shields.io/badge/Wine-ghcr.io%2Fgoover%2Fwine%3Astaging-722f37?style=flat-square&logo=wine&logoColor=white)](https://github.com/gOOvER)
  [![BepInEx](https://img.shields.io/badge/ModLoader-BepInEx%20IL2CPP-orange?style=flat-square)](https://v-rising.thunderstore.io/package/BepInEx/BepInExPack_V_Rising/)
  [![Steam AppID](https://img.shields.io/badge/Steam%20AppID-1829350-1b2838?style=flat-square&logo=steam&logoColor=white)](https://steamdb.info/app/1829350/)
  [![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENCE.md)
  [![Support](https://img.shields.io/badge/Donate-Ko--fi-ff69b4?style=flat-square&logo=ko-fi&logoColor=white)](https://donate.goover.dev)

</div>

---

## Author & Contributors

| Name | Role | GitHub Profile | Support |
|------|------|----------------|---------|
| **gOOvER** | Maintainer & Fixes | https://github.com/gOOvER | [![donate](https://img.shields.io/badge/Donate-Ko--fi-red?style=flat-square)](https://donate.goover.dev) |
| **David Wolfe (Red-Thirten)** | Original Author | https://github.com/Red-Thirten | — |
| **Kapatheus** | Original Contributor | — | — |

---

## About V Rising

**V Rising** is an open-world vampire survival game where you awaken after centuries of slumber, hunt for blood to regain your strength, hide from the scorching sun, build your castle, and conquer the land of the living alone or with allies online.

- **Steam Store:** [store.steampowered.com/app/1604030](https://store.steampowered.com/app/1604030/V_Rising/)
- **SteamDB (Dedicated Server):** [steamdb.info/app/1829350](https://steamdb.info/app/1829350/)

---

## About this Egg

This egg runs the **Windows-native V Rising dedicated server** via **Wine** (`ghcr.io/goover/wine:staging`) and installs/updates **BepInEx (IL2CPP)** automatically from Thunderstore (`BepInExPack_V_Rising`).

### Included Fixes & Improvements
- Preserves the bundled BepInEx `dotnet/` CoreCLR runtime required by `doorstop_config.ini`.
- Properly exports `WINEDLLOVERRIDES="winhttp=n,b"` in the startup command.
- Cleans up stale `.wine` / `.cache` / `BepInEx/interop` directories on reinstall/update to prevent prefix and memory allocation errors.
- Supports `VALIDATE` for SteamCMD file verification and maps `ListOnSteam` / `ListOnEOS` cleanly in `ServerHostSettings.json`.

> [!IMPORTANT]
> **Memory Requirement (First Startup):** Generating the IL2CPP interop assemblies (`Cpp2IL` / `Il2CppInterop`) on the first boot causes a temporary RAM spike of **6–8+ GB**. Make sure your server container has sufficient memory allocated, otherwise BepInEx may crash with `System.OutOfMemoryException`.

---

## Download this Egg

This is a **Pelican** YAML egg ([egg-v-rising-bep-in-ex.yaml](egg-v-rising-bep-in-ex.yaml)).

> [!TIP]
> **Pterodactyl users:** You can get a Pterodactyl-compatible version in two ways:
> - 🔀 Convert it yourself with **[Scramble Egg Converter](https://redthirten.github.io/scramble-egg-converter/)**
> - 💬 Download a pre-built version via `/egg download` in our **[Discord server](http://discord.gg/raurR4vshX)**

---

## Server Ports

| Port | Default | Protocol | Description |
|------|---------|----------|-------------|
| **Game Port** | `9876` | UDP | Main game connection port (Primary Allocation) |
| **Query Port** | `9877` | UDP | Steam query port |
| **RCON Port** | `25575` | TCP | Remote console (optional, disabled by default) |

---

## Support

Support is provided exclusively via Discord.

[![Join our Discord server!](https://invidget.switchblade.xyz/raurR4vshX)](http://discord.gg/raurR4vshX)

---

## Home Hosting

I cannot and will not provide support for servers hosted at home. 99 % of such issues are caused by incorrect network settings across many different configurations — I simply don't have the time to debug them individually.

---

## Tags

`survival` `vampire` `steam` `multiplayer` `open-world` `wine` `bepinex` `il2cpp`

---

## License

This Egg is licensed under the [MIT](LICENCE.md) license.
