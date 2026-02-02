# Generic Installation Script for Pelican Eggs

This is a generic installation script template for Pelican/Pterodactyl game server eggs on Linux.

## Features

- Automatic SteamCMD or DepotDownloader installation
- Comprehensive system information check
- Automatic dependency installation (Alpine/Debian/Ubuntu)
- Retry logic for downloads
- Steam library setup
- Optional configuration file download
- Optional library file copying
- Steam AppID file generation
- Detailed logging

## Configuration

### Basic Settings (Lines 20-41)

Edit these variables at the top of the script to configure your game server installation:

```bash
GAME_NAME="YourGame"                    # Name of your game (for display)
CONFIG_INIT=0                           # Set to 1 to enable config download
CONFIG_FILE_NAME="Game.ini"             # Name of the config file
CONFIG_DIR="$HOME/config"               # Directory for config file
CONFIG_URL="https://..."                # URL to download default config
STEAMCMD_DIR="$HOME/steamcmd"           # SteamCMD installation directory
LIB_COPY_ITEMS=()                       # Library copying configuration
SteamAppId=""                           # Client AppID for steam_appid.txt
```

### Optional Features

#### Library Copying

Copy libraries or files after installation:

```bash
LIB_COPY_ITEMS=(
    "$HOME/steamcmd/linux64/steamclient.so|$HOME/.steam/sdk64/steamclient.so"
    "$HOME/game/lib/libfoo.so|$HOME/game/libfoo.so"
)
```

Format: `"source_path|destination_path"`

#### Steam AppID File

Create a `steam_appid.txt` file with the client App ID:

```bash
SteamAppId="2644050"  # Client App ID (different from server App ID)
```

The file will be created in `$HOME/steam_appid.txt` if this variable is set.

#### Config File Download

Enable automatic config download if not present:

```bash
CONFIG_INIT=1
CONFIG_FILE_NAME="server.cfg"
CONFIG_DIR="$HOME/config"
CONFIG_URL="https://raw.githubusercontent.com/user/repo/main/server.cfg"
```

## Usage in Pelican Eggs

### Install Script

Set this as your egg's install script:

```json
{
  "script": "#!/bin/bash\n# Download and run the script\ncurl -sSL https://raw.githubusercontent.com/gsrvtech/gameserver-templates/main/_scripts/egg-install-script.sh | bash"
}
```

Or copy the script content directly into your egg.

### Required Variables

In your egg's `egg-*.json`, define at minimum:

```json
{
  "variables": [
    {
      "name": "Steam App ID",
      "description": "Steam App ID for the dedicated server",
      "env_variable": "STEAM_APPID",
      "default_value": "123456",
      "user_viewable": true,
      "user_editable": false,
      "rules": "required|numeric"
    }
  ]
}
```

### Optional Variables

```json
{
  "name": "Steam Client App ID",
  "description": "Client App ID for steam_appid.txt (leave empty if not needed)",
  "env_variable": "SteamAppId",
  "default_value": "",
  "user_viewable": true,
  "user_editable": true,
  "rules": "nullable|numeric"
}
```

## System Information

The script automatically detects and logs:

- Operating System / Kernel version
- CPU model and core count
- Virtualization type (KVM, VMware, Hyper-V, Xen, QEMU, Docker, LXC)
- RAM (total, available, used, percentage)
- Disk space

Information is saved to `$HOME/system_info.txt` and the install log.

## Logging

All operations are logged to: `$HOME/{GAME_NAME}_install.log`

The log includes:
- Timestamps for all operations
- Download attempts and results
- SteamCMD/DepotDownloader output
- Error messages and warnings
- System information

## Error Handling

The script includes:

- Automatic dependency installation
- Download retry logic (3 attempts)
- Network connectivity checks
- Path validation
- Steam credential validation
- File existence checks before copying

## Customization

### Adding Custom Commands

Add your game-specific commands in the "Game-specific Hooks" section:

```bash
# ----------------------------
# Game-specific Hooks
# ----------------------------
echo ""
echo "${BLUE}┌─ ${CYAN}${BOLD}Game-specific Hooks${NC}"
print_step "Executing custom commands..."

# Add your commands here
chmod +x "$HOME/server_binary"
ln -s "$HOME/lib/libsteam.so" "$HOME/libsteam.so"

copy_game_libs
# ... rest of the section
```

### Available Helper Functions

- `print_step "message"` - Print a step indicator
- `print_ok "message"` - Print success message
- `print_warn "message"` - Print warning message
- `print_error "message"` - Print error message
- `copy_game_libs` - Copy libraries from `LIB_COPY_ITEMS`
- `download_with_retry url output retries desc` - Download with retry logic

## Examples

### Example 1: Basic SteamCMD Installation

```bash
GAME_NAME="My Game Server"
STEAMCMD_DIR="$HOME/steamcmd"
LIB_COPY_ITEMS=()
SteamAppId=""

# Set via environment variables:
# STEAM_APPID=123456
```

### Example 2: Windows Server with Beta Branch

```bash
GAME_NAME="Windows Game"
STEAMCMD_DIR="$HOME/steamcmd"
LIB_COPY_ITEMS=()
SteamAppId=""

# Set via environment variables:
# STEAM_APPID=123456
# WINDOWS_INSTALL=1
# STEAM_BETAID=experimental
```

### Example 3: With Config and Libraries

```bash
GAME_NAME="Advanced Game"
CONFIG_INIT=1
CONFIG_FILE_NAME="server.cfg"
CONFIG_DIR="$HOME/config"
CONFIG_URL="https://example.com/server.cfg"
STEAMCMD_DIR="$HOME/steamcmd"

LIB_COPY_ITEMS=(
    "$HOME/steamcmd/linux64/steamclient.so|$HOME/.steam/sdk64/steamclient.so"
)

SteamAppId="123456"

# Set via environment variables:
# STEAM_APPID=654321
```

## Troubleshooting

### Installation Fails

1. Check the log file: `cat $HOME/{GAME_NAME}_install.log`
2. Verify `STEAM_APPID` is correct
3. Check if the app requires authentication (not anonymous)
4. Try setting `WINDOWS_INSTALL=1` if it's a Windows-only server

### Libraries Not Copying

1. Verify paths in `LIB_COPY_ITEMS` are correct
2. Check if source files exist after SteamCMD finishes
3. Look for "Source not found" errors in the log

### Missing Configuration Error

This usually means:
1. App requires a beta branch - set `STEAM_BETAID`
2. App is Windows-only - set `WINDOWS_INSTALL=1`
3. Wrong App ID
4. App requires authentication

## License

AGPLv3

## Author

gOOvER - https://discord.goover.dev

## Support

https://donate.goover.dev
