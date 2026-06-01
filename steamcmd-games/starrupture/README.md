# Star Rupture

## Author & Contributors

| Name   | GitHub Profile               | Buy me a Coffee                                       |
|--------|------------------------------|-------------------------------------------------------|
| gOOvER | https://github.com/gOOvER   | [![donate](https://img.shields.io/badge/Donate-Ko--fi-red)](https://donate.goover.dev) |

---

## About Star Rupture

**StarRupture** is a first-person open-world base-building game with advanced combat and tons of exploration. Play alone or with up to 4 friends on this sublime and ever-changing planet — extract and manage resources, create a complex industrial system, and fight off hordes of alien monsters.

---

## Download this Egg

This is a **Pelican** YAML egg.

> **Pterodactyl users:** You can get a Pterodactyl-compatible version in two ways:
> - 🔀 Convert it yourself with **[Scramble Egg Converter](https://redthirten.github.io/scramble-egg-converter/)**
> - 💬 Download a pre-built version via `/egg download` in our **[Discord server](http://discord.gg/raurR4vshX)**

---

## Server Ports

| Port       | Default               | Description               |
|------------|-----------------------|---------------------------|
| Game Port  | 7777 (configurable)   | Main game connection port |

---

## Configuration

The server uses a `DSSettings.txt` configuration file located in the server root directory.

For detailed configuration options, visit the official documentation:
**https://wiki.starrupture-utilities.com/en/dedicated-server/configuration**

### Key Settings

| Variable       | Description                                               | Default | Editable |
|----------------|-----------------------------------------------------------|---------|----------|
| Session Name   | Name of the save game session                             | —       | Yes      |
| Save Interval  | Time between automatic saves (in seconds)                 | 300     | Yes      |
| Start New Game | Forces creation of a new world (set to true only once!)   | false   | Yes      |
| Load Saved Game| Loads an existing save                                    | true    | Yes      |
| Savegame Name  | Filename of the save to load                              | —       | Yes      |
| AutoUpdate     | Enable automatic server updates                           | 1       | Yes      |

### Setting Admin & Join Passwords

To secure your server with admin and player passwords:

1. Visit **https://starrupture-utilities.com/passwords**
2. Generate both an **Admin password** and a **Player Password**
3. Create `Password.json` and paste the contents of the site's **password.json** field into it
4. Create `PlayerPassword.json` and paste the contents of the site's **playerpassword.json** field into it
5. Upload both files to the root directory of your server (alongside `StarRuptureServerEOS.exe`)

> **Note**: Both password files must be placed in the server root directory to take effect.
> **Start New Game**: Only set this to `true` when creating a new world for the first time — set it back to `false` afterwards.

---

## Logs

Server logs can be found at:

```
./StarRupture/Saved/Logs/StarRupture.log
```

---

## Support

Support is provided exclusively via Discord.

[![Join our Discord server!](https://invidget.switchblade.xyz/raurR4vshX)](http://discord.gg/raurR4vshX)

---

## Home Hosting

I cannot and will not provide support for servers hosted at home. 99 % of such issues are caused by incorrect network settings across many different configurations — I simply don't have the time to debug them individually.

---

## License

This Egg is licensed under the [AGPLv3](LICENCE.md) licence.