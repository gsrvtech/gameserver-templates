# V Rising (BepInEx)

## Author & Contributors

| Name                         | GitHub Profile                      | Buy me a Coffee                                                                    |
|------------------------------|-------------------------------------|------------------------------------------------------------------------------------|
| gOOvER                       | https://github.com/gOOvER           | [![donate](https://img.shields.io/badge/Donate-Ko--fi-red)](https://donate.goover.dev) |
| David Wolfe (Red-Thirten)    | https://github.com/Red-Thirten      | —                                                                                  |
| Kapatheus                    | —                                   | —                                                                                  |

---

## About V Rising

**V Rising** is an open-world vampire survival game where you awaken after centuries of slumber, hunt for blood to regain your strength, hide from the scorching sun, build your castle, and conquer the land of the living alone or with allies online.

- **Steam**: [store.steampowered.com/app/1604030](https://store.steampowered.com/app/1604030/V_Rising/)
- **SteamDB (Dedicated Server)**: [steamdb.info/app/1829350](https://steamdb.info/app/1829350/)

---

## About this Egg

This egg runs the **Windows-native V Rising dedicated server** via **Wine** (`ghcr.io/goover/wine:staging`) with **BepInEx (IL2CPP)** automatically installed and updated from Thunderstore (`BepInExPack_V_Rising`).

> **Important (First Startup / RAM):** Generating the IL2CPP interop assemblies (`Cpp2IL` / `Il2CppInterop`) during the first start requires a temporary RAM spike of **6–8+ GB**. Make sure the server container has enough memory allocated.

---

## Download this Egg

This is a **Pelican** YAML egg (`egg-v-rising-bep-in-ex.yaml`).

> **Pterodactyl users:** You can get a Pterodactyl-compatible version in two ways:
> - 🔀 Convert it yourself with **[Scramble Egg Converter](https://redthirten.github.io/scramble-egg-converter/)**
> - 💬 Download a pre-built version via `/egg download` in our **[Discord server](http://discord.gg/raurR4vshX)**

---

## Server Ports

| Port        | Default      | Description               |
|-------------|--------------|---------------------------|
| Game Port   | 9876         | Main game connection port |
| Query Port  | 9877         | Steam query port          |
| RCON Port   | 25575        | Remote console (RCON)     |

---

## Support

Support is provided exclusively via Discord.

[![Join our Discord server!](https://invidget.switchblade.xyz/raurR4vshX)](http://discord.gg/raurR4vshX)

---

## Home Hosting

I cannot and will not provide support for servers hosted at home. 99 % of such issues are caused by incorrect network settings across many different configurations — I simply don't have the time to debug them individually.

---

## Tags

`survival`, `vampire`, `steam`, `multiplayer`, `open-world`, `wine`, `bepinex`, `il2cpp`

---

## License

This Egg is licensed under the [MIT](LICENCE.md) license.
