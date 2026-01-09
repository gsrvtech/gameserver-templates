# Star Rupture

## Author & Contributors
| Name        | Github Profile  | Buy me a Coffee |
| ------------- |-------------|-------------|
|   gOOvER   | https://github.com/gOOvER | [Donate](https://donate.goover.dev) |

## Game Description

StarRupture is a first-person open-world base building game with advanced combat and tons of exploration. Play alone or with up to 4 friends on this sublime and everchanging planet, extract and manage resources, create your complex industrial system, and fight off hordes of alien monsters.

## Server Ports

| Port  | Default |
|-------|---------|
| Game Port  | 7777 (configurable)    |

## Configuration

The server uses a `DSSettings.txt` configuration file located in the server root directory.

For detailed configuration options, visit the official documentation:
**https://wiki.starrupture-utilities.com/en/dedicated-server/configuration**

### Key Settings

| Variable | Description | Default | Editable |
|----------|-------------|---------|----------|
| Session Name | Name of the save game session | - | Yes |
| Save Interval | Time between automatic saves (in seconds) | 300 | Yes |
| Start New Game | Forces creation of a new world (set to true only once!) | false | Yes |
| Load Saved Game | Loads an existing save | true | Yes |
| Savegame Name | Filename of the save to load | - | Yes |
| AutoUpdate | Enable automatic server updates | 1 | Yes |

### Setting Admin & Join Passwords

To secure your server with admin and player passwords:

1. Visit **https://starrupture-utilities.com/passwords**
2. Generate both an **Admin password** and a **Player Password**
3. Create `Password.json` and paste the contents of the site's **password.json** field into it
4. Create `PlayerPassword.json` and paste the contents of the site's **playerpassword.json** field into it
5. Upload both files to the root directory of your server (alongside `StarRuptureServerEOS.exe`)

**Note**: Both password files must be placed in the server root directory to take effect.

### Important Notes

- **Start New Game**: Only set this to `true` when creating a new world for the first time. After the world is created, set it back to `false`.
- **Savegame Name**: Must exist in the server save directory
- **Save Interval**: Recommended minimum is 300 seconds (5 minutes)
- **Password Files**: Use the official password generator to create properly formatted password files

## Logs

Server logs can be found at:
```
./StarRupture/Saved/Logs/StarRupture.log
```

## Support

For issues or questions:

- Support: https://discord.goover.dev
- Donations: https://donate.goover.dev


