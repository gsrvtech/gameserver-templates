<div align="center">

<img src="https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/251570/header.jpg?t=1793815172" alt="7 Days To Die Banner" width="460" />

# 7 Days To Die

[![Pelican](https://img.shields.io/badge/Pelican-PLCN__v3-111114?style=flat-square)](https://pelican.dev)
[![Pterodactyl](https://img.shields.io/badge/Pterodactyl-PTDL__v2-111114?style=flat-square)](https://pterodactyl.io)
[![Steam Store](https://img.shields.io/badge/Steam-Store-1b2838?style=flat-square&logo=steam)](https://store.steampowered.com/app/294420)
[![SteamDB](https://img.shields.io/badge/SteamDB-Info-1b2838?style=flat-square&logo=steam)](https://steamdb.info/app/294420)
[![License](https://img.shields.io/badge/License-AGPL--3.0-blue?style=flat-square)](https://www.gnu.org/licenses/agpl-3.0.html)

</div>

## Description

7 Days to Die is an open-world game that is a unique combination of first-person shooter, survival
horror, tower defense, and role-playing games.

## Server Information

| Property | Value |
| --- | --- |
| **Type** | Steam (`AppID 294420`) |
| **Anonymous Login** | Yes |

## Server Ports

| Port | Default | Protocol | Notes |
| --- | --- | --- | --- |
| **Game** | `27015` | UDP | Primary server port |
| **Query** | `27015` | UDP | Steam query port |

## Docker Images

- `ghcr.io/goover/steamcmd:debian`

<details>
<summary><strong>Environment Variables</strong></summary>

| Variable | Default | Description |
| --- | --- | --- |
| `AUTO_UPDATE` | `1` | This is to auto update the server on start. Options are 0 or 1 Default is 1 |
| `DASHBOARD_PORT` | - | - |
| `GAME_DIFFICULTY` | `2` | 0 - 5, 0=easiest, 5=hardest |
| `GAME_MODE` | `GameModeSurvival` | GameModeSurvival |
| `GAME_NAME` | `My Game` | Whatever you want the game name to be. This affects the save game name as well as the seed used when placing decoration (trees etc) in the world. It does not control the generic layout of the world if creating an RWG world |
| `GAME_WORLD` | `Navezgane` | "RWG" (see WorldGenSeed and WorldGenSize options below) or any already existing world name in the Worlds folder (currently shipping with e.g. "Navezgane", "PREGEN01", ...) |
| `LANGUAGE` | `English` | rimary language for players on this server. Values: Use any language name that you would users expect to search for. Should be the English name of the language, e.g. not "Deutsch" but "German" |
| `LD_LIBRARY_PATH` | `.` | This is really annoying that more games are doing this. |
| `MAX_PLAYERS` | `8` | Maximum Concurrent Players |
| `REGION` | `Europe` | - |
| `SERVER_DISABLED_NETWORK_PROTOCOLS` | - | Networking protocols that should NOT be used. Separated by comma. Possible values: LiteNetLib, SteamNetworking. Dedicated servers should disable SteamNetworking if there is no NAT router in between your users and the server or when port-forwarding is set up correctly. lets it empty if you are connecting your self hosted server behind a NAT |
| `SRV_DESCRIPTION` | `Egg by gameserver.tech` | - |
| `SRV_NAME` | - | - |
| `SRV_PW` | - | - |
| `STEAM_APPID` | `294420` | This is the app id for 7dtd please no step on snek. |
| `STEAM_BETAID` | - | Installs beta branch if specified. For example, latest_experimental would install the latest experimental branch release. Requires a reinstall to switch branches properly. |
| `TELNET_PORT` | - | - |
| `TELNET_PW` | - | Telnet listens on a local interface by default without a password. However, you can specify a password if you wish to expose telnet. |
| `WEB_URL` | - | Website URL for the server, will be shown in the serverbrowser as a clickable link |
| `WEBDASHBOARD` | `false` | Enable/disable the web dashboard |
| `WORLD_SEED` | `asdf` | If RWG this is the seed for the generation of the new world. If a world with the resulting name already exists it will simply load it |
| `WORLD_SIZE` | `6192` | If RWG this controls the width and height of the created world. It is also used in combination with WorldGenSeed to create the internal RWG seed thus also creating a unique map name even if using the same WorldGenSeed. Has to be between 2048 and 16384, though large map sizes will take long to generate / download / load |

</details>

## Installation

1. Download the egg file (**Pelican `.yaml`** or **Pterodactyl `.json`**).
2. In your panel, open **Admin → Eggs → Import Egg** and upload the file.
3. Create a new server using the imported egg and adjust the environment variables as needed.

## Author & License

- **Author:** eggs@goover.dev
- **Co-Authors:** <!-- Add co-authors here -->
- **License:** Licensed under the [**AGPL-3.0**](https://www.gnu.org/licenses/agpl-3.0.html) license.
