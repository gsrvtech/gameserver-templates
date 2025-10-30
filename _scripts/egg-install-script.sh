#!/bin/bash
# ------------------------------------------------
# Generic Installscript Template for Pelican Eggs (Linux)
# License: AGPLv3
# Author: gOOvER (https://discord.goover.dev)
# Donate: https://donate.goover.dev
# ------------------------------------------------

set -euo pipefail  # Strict error handling

# ----------------------------
# Environment Setup
# ----------------------------
HOME=/mnt/server
export HOME

# Ensure /mnt is owned by root
chown -R root:root /mnt

GAME_NAME="Risk of Rain2"   # <--- name of the game (internal placeholder)
CONFIG_INIT=0
CONFIG_FILE_NAME="Game.ini"      # <--- configurable config filename (internal)
CONFIG_DIR="$HOME/PATH_TO_INI" # <--- adjustable per game
CONFIG_URL="https://URL_TO_RAW_FILE_ON_GITHUB/$CONFIG_FILE_NAME"                  # <--- adjustable per game
STEAMCMD_DIR="$HOME/steamcmd"              # <--- SteamCMD directory

STEAM_USER="${STEAM_USER:-anonymous}"
STEAM_PASS="${STEAM_PASS:-}"
STEAM_AUTH="${STEAM_AUTH:-}"
DEPOTDOWNLOADER="${DEPOTDOWNLOADER:-0}"
: "${STEAM_APPID:?Environment variable STEAM_APPID must be set for $GAME_NAME}"  # mandatory

# ----------------------------
# Locale Setup to suppress warnings
# ----------------------------
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8

# ----------------------------
# Logging Setup
# ----------------------------
SAFE_NAME="${GAME_NAME// /_}_install.log"
INSTALL_LOG="$HOME/$SAFE_NAME"

# Redirect all output to log while still mirroring to console
if command -v tee >/dev/null 2>&1; then
    exec 3>&1 4>&2
    exec > >(tee -a "$INSTALL_LOG" >&3) 2> >(tee -a "$INSTALL_LOG" >&2)
else
    exec > "$INSTALL_LOG" 2>&1
fi

# ----------------------------
# Colors
# ----------------------------
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
BLUE=$(tput setaf 4 2>/dev/null || echo "")
CYAN=$(tput setaf 6 2>/dev/null || echo "")
NC=$(tput sgr0 2>/dev/null || echo "")

LINE="${BLUE}-------------------------------------------------${NC}"

# ----------------------------
# Logging Functions
# ----------------------------
log_info()    { echo "$(date '+%Y-%m-%d %H:%M:%S') ${BLUE}[INFO]${NC} $*"; }
log_warn()    { echo "$(date '+%Y-%m-%d %H:%M:%S') ${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo "$(date '+%Y-%m-%d %H:%M:%S') ${RED}[ERROR]${NC} $*" >&2; }
log_success() { echo "$(date '+%Y-%m-%d %H:%M:%S') ${GREEN}[ OK ]${NC} $*"; }

# ----------------------------
# Validation Functions
# ----------------------------
validate_steam_appid() {
    if [[ ! "$STEAM_APPID" =~ ^[0-9]+$ ]]; then
        log_error "STEAM_APPID must be numeric: $STEAM_APPID"
        exit 1
    fi
}

validate_config_url() {
    # Only validate if CONFIG_INIT is enabled
    if [[ "${CONFIG_INIT:-0}" -eq 1 ]] && [[ -n "$CONFIG_URL" ]]; then
        if [[ ! "$CONFIG_URL" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
            log_error "CONFIG_URL must be a valid HTTP/HTTPS URL: $CONFIG_URL"
            exit 1
        fi
        
        # Check for suspicious URLs
        if [[ "$CONFIG_URL" =~ (localhost|127\.0\.0\.1|0\.0\.0\.0|::1) ]]; then
            log_warn "CONFIG_URL points to localhost - this may be intentional but could be suspicious"
        fi
    fi
}

# New function for additional security checks
validate_steam_credentials() {
    # Check for suspicious characters in Steam credentials
    local suspicious_chars='[;&|`$()]'
    
    if [[ "$STEAM_USER" =~ $suspicious_chars ]]; then
        log_error "STEAM_USER contains suspicious characters"
        exit 1
    fi
    
    if [[ -n "$STEAM_PASS" ]] && [[ "$STEAM_PASS" =~ $suspicious_chars ]]; then
        log_error "STEAM_PASS contains suspicious characters"
        exit 1
    fi
    
    if [[ -n "$STEAM_AUTH" ]] && [[ "$STEAM_AUTH" =~ $suspicious_chars ]]; then
        log_error "STEAM_AUTH contains suspicious characters"
        exit 1
    fi
}

validate_path() {
    local path="$1"
    local name="$2"
    
    # Check for path traversal attempts
    if [[ "$path" =~ \.\./\.\. ]] || [[ "$path" =~ ^/etc ]] || [[ "$path" =~ ^/root ]]; then
        log_error "Invalid or dangerous path for $name: $path"
        exit 1
    fi
    
    # Ensure path starts with $HOME
    if [[ ! "$path" =~ ^$HOME ]]; then
        log_error "Path $name must start with HOME directory: $path"
        exit 1
    fi
}

check_dependencies() {
    local deps=("curl" "tar")
    local missing=()
    local optional_deps=("wget" "unzip")
    
    # Check if curl supports HTTPS
    local curl_https_support=false
    if command -v curl >/dev/null 2>&1; then
        if curl --version 2>/dev/null | grep -q "https"; then
            curl_https_support=true
        else
            log_warn "curl found but HTTPS support is missing"
        fi
    else
        missing+=("curl")
    fi
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    # Try to install missing dependencies automatically
    if [ ${#missing[@]} -gt 0 ] || [ "$curl_https_support" = "false" ]; then
        log_warn "Attempting to install missing dependencies..."
        
        # Alpine Linux
        if command -v apk >/dev/null 2>&1; then
            log_info "Detected Alpine Linux, installing packages..."
            apk add --no-cache curl ca-certificates openssl tar wget 2>/dev/null || {
                log_error "Failed to install packages via apk"
                log_error "Missing required dependencies: ${missing[*]}"
                exit 1
            }
        # Debian/Ubuntu
        elif command -v apt-get >/dev/null 2>&1; then
            log_info "Detected Debian/Ubuntu, installing packages..."
            export DEBIAN_FRONTEND=noninteractive
            apt-get update >/dev/null 2>&1 || true
            apt-get install -y curl ca-certificates openssl tar wget gnupg2 2>/dev/null || {
                log_error "Failed to install packages via apt-get"
                log_error "Missing required dependencies: ${missing[*]}"
                exit 1
            }
            # Update CA certificates to ensure HTTPS works properly
            update-ca-certificates >/dev/null 2>&1 || true
        else
            log_error "Unsupported Linux distribution"
            log_error "This script only supports Alpine Linux and Debian/Ubuntu"
            log_error "Missing required dependencies: ${missing[*]}"
            log_error "Please install them manually before running this script"
            exit 1
        fi
        
        log_success "Dependencies installed successfully"
    fi
    
    # Re-check dependencies after installation
    missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Still missing dependencies after installation: ${missing[*]}"
        exit 1
    fi
    
    # Check optional dependencies
    for dep in "${optional_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log_warn "Optional dependency missing: $dep (recommended for better functionality)"
        fi
    done
    
    # Check system requirements
    if [ "$(nproc 2>/dev/null || echo 1)" -lt 2 ]; then
        log_warn "System has less than 2 CPU cores - installation may be slow"
    fi
    
    local available_memory
    available_memory=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
    if [ "$available_memory" -lt 1024 ]; then
        log_warn "Less than 1GB available memory - installation may fail"
    fi
    
    log_success "All required dependencies found"
}

# ----------------------------
# Download with Retry Function
# ----------------------------
download_with_retry() {
    local url="$1" 
    local output="$2" 
    local retries="${3:-3}"
    local desc="${4:-file}"
    local expected_size="${5:-}"
    
    # Validate URL format
    if [[ ! "$url" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
        log_error "Invalid URL format: $url"
        return 1
    fi
    
    # Check if HTTPS is supported by curl
    local curl_supports_https=true
    if ! curl --version 2>/dev/null | grep -q "https"; then
        curl_supports_https=false
        log_warn "HTTPS not supported by curl, will use HTTP if available"
    fi
    
    # Convert HTTPS to HTTP if HTTPS is not supported
    local download_url="$url"
    if [[ "$url" =~ ^https:// ]] && [[ "$curl_supports_https" == "false" ]]; then
        download_url="${url/https:/http:}"
        log_warn "Converting HTTPS URL to HTTP: $download_url"
    fi
    
    for i in $(seq 1 "$retries"); do
        log_info "Downloading $desc (attempt $i/$retries)..."
        
        # Try with original URL first, then HTTP fallback if needed
        local urls_to_try=("$url")
        if [[ "$url" =~ ^https:// ]] && [[ "$url" != "$download_url" ]]; then
            urls_to_try=("$url" "$download_url")
        fi
        
        local success=false
        for try_url in "${urls_to_try[@]}"; do
            # Use appropriate curl options based on protocol
            local curl_opts=(
                -fsSL
                --connect-timeout 30
                --max-time 300
                --retry 2
                --retry-delay 1
                --retry-max-time 60
                --location
                -H "User-Agent: GameServer-Installer/1.0"
                -o "$output"
            )
            
            # Add protocol and TLS options only if supported
            if [[ "$try_url" =~ ^https:// ]] && [[ "$curl_supports_https" == "true" ]]; then
                curl_opts+=(--proto '=https,=http' --tlsv1.2)
            else
                curl_opts+=(--proto '=http')
            fi
            
            if curl "${curl_opts[@]}" "$try_url"; then
                success=true
                break
            fi
        done
        
        if [[ "$success" == "true" ]]; then
            # Verify download
            if [[ -f "$output" ]]; then
                local file_size
                file_size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null || echo 0)
                
                if [[ "$file_size" -gt 0 ]]; then
                    if [[ -n "$expected_size" ]] && [[ "$file_size" -lt "$expected_size" ]]; then
                        log_warn "Downloaded file seems too small ($file_size bytes, expected at least $expected_size)"
                    fi
                    log_success "Downloaded $desc successfully ($file_size bytes)"
                    return 0
                else
                    log_error "Downloaded file is empty"
                    rm -f "$output"
                fi
            fi
        fi
        
        if [ "$i" -lt "$retries" ]; then
            log_warn "Download attempt $i failed, retrying in 5 seconds..."
            sleep 5
        fi
    done
    
    log_error "Failed to download $desc after $retries attempts"
    return 1
}

# ----------------------------
# Safe command execution
# ----------------------------
run_or_fail() {
    local desc="$1"; shift
    log_info "Starting: $desc"
    
    if "$@"; then
        log_success "$desc"
    else
        local exit_code=$?
        log_error "$desc failed with exit code $exit_code"
        exit 1
    fi
}

# ----------------------------
# Cleanup Function
# ----------------------------
cleanup() {
    local exit_code=$?
    log_info "Cleaning up temporary files..."
    
    # Remove temporary files
    rm -f /tmp/steamcmd.tar.gz /tmp/depotdownloader.zip /tmp/steam_output.log
    
    # Clean up any leftover processes
    pkill -f "steamcmd" 2>/dev/null || true
    pkill -f "DepotDownloader" 2>/dev/null || true
    
    # Clear sensitive variables
    unset STEAM_PASS STEAM_AUTH
    
    # Restore original file descriptors if they were changed
    if [ -n "${original_stdout:-}" ]; then
        exec 1>&3 2>&4
        exec 3>&- 4>&-
    fi
    
    if [ $exit_code -ne 0 ]; then
        log_error "Script exited with error code $exit_code"
        log_info "Check the installation log at: $INSTALL_LOG"
    fi
    
    exit $exit_code
}

trap cleanup EXIT

# ----------------------------
# Secure Steam Command Execution
# ----------------------------
run_steam_command() {
    local -a cmd_array=()
    local desc="$2"
    
    # Parse command array from first argument
    eval "cmd_array=($1)"
    
    log_info "Executing: $desc"
    
    local exit_code=0
    local log_file="/tmp/steam_output.log"
    
    # Execute command with proper output handling
    if [[ -n "$STEAM_PASS" ]]; then
        # Redirect sensitive output to temp file
        "${cmd_array[@]}" > "$log_file" 2>&1 || exit_code=$?
        # Log non-sensitive parts only
        if [[ $exit_code -eq 0 ]]; then
            grep -v "password\|auth" "$log_file" | tail -20 || true
        fi
        rm -f "$log_file"
    else
        "${cmd_array[@]}" || exit_code=$?
    fi
    
    case $exit_code in
        0) log_success "$desc completed successfully" ;;
        2) log_error "Steam login failed - check credentials" ;;
        5) log_error "App not found or access denied for AppID: $STEAM_APPID" ;;
        7) log_error "Steam is updating, please try again later" ;;
        *) 
            if [ $exit_code -ne 0 ]; then
                log_warn "$desc exited with code $exit_code, but installation may still be OK"
            fi
            ;;
    esac
    
    return $exit_code
}

# ----------------------------
# Start Script Output
# ----------------------------
clear
log_info "$LINE"
log_info "${YELLOW}$GAME_NAME Installscript${NC}"
log_info "$LINE"

# ----------------------------
# Pre-flight Checks
# ----------------------------
log_info "Running pre-flight checks..."
check_dependencies
validate_steam_appid
validate_config_url
validate_steam_credentials
validate_path "$CONFIG_DIR" "CONFIG_DIR"
validate_path "$STEAMCMD_DIR" "STEAMCMD_DIR"

# Check network connectivity
log_info "Testing network connectivity..."
if ! curl -s --connect-timeout 10 --max-time 15 "https://steamcdn-a.akamaihd.net" >/dev/null 2>&1; then
    log_warn "HTTPS connection to Steam servers failed, trying HTTP..."
    if ! curl -s --connect-timeout 10 --max-time 15 "http://steamcdn-a.akamaihd.net" >/dev/null 2>&1; then
        log_error "Cannot reach Steam servers via HTTP or HTTPS. Check your internet connection."
        exit 1
    else
        log_warn "Network connectivity verified via HTTP (HTTPS unavailable)"
    fi
else
    log_success "Network connectivity verified via HTTPS"
fi

if [ "$STEAM_USER" = "anonymous" ]; then
    log_warn "Using anonymous Steam login for $GAME_NAME."
else
    log_info "Using Steam user: $STEAM_USER for $GAME_NAME."
fi

# ----------------------------
# Game Installation via DepotDownloader
# ----------------------------
if [ "$DEPOTDOWNLOADER" = "1" ]; then
    log_info "Installing $GAME_NAME via DepotDownloader (Linux)..."
    mkdir -p "$HOME/depotdownloader"
    cd "$HOME/depotdownloader"

    if [ ! -f DepotDownloader ]; then
        log_info "Fetching DepotDownloader Linux binary..."
        run_or_fail "Download DepotDownloader" \
            download_with_retry \
            "https://github.com/SteamRE/DepotDownloader/releases/latest/download/DepotDownloader-Linux-x64" \
            "DepotDownloader" \
            3 \
            "DepotDownloader binary"
        
        run_or_fail "Make DepotDownloader executable" chmod +x DepotDownloader
    fi

    # Build DepotDownloader command array
    declare -a dd_cmd=(
        "./DepotDownloader"
        "-app" "$STEAM_APPID"
        "-dir" "$HOME"
    )
    
    if [[ -n "${STEAM_BETAID:-}" ]]; then
        dd_cmd+=("-beta" "$STEAM_BETAID")
    fi
    
    if [[ -n "${STEAM_BETAPASS:-}" ]]; then
        dd_cmd+=("-betapassword" "$STEAM_BETAPASS")
    fi
    
    # Add install flags if provided
    if [[ -n "${INSTALL_FLAGS:-}" ]]; then
        read -ra flags <<< "$INSTALL_FLAGS"
        dd_cmd+=("${flags[@]}")
    fi
    
    dd_cmd+=("-username" "$STEAM_USER")
    
    if [[ -n "$STEAM_PASS" ]]; then
        dd_cmd+=("-password" "$STEAM_PASS")
    fi
    
    if [[ -n "$STEAM_AUTH" ]]; then
        dd_cmd+=("-remember-password" "$STEAM_AUTH")
    fi

    # Convert array to string for run_steam_command
    cmd_string=""
    printf -v cmd_string '%q ' "${dd_cmd[@]}"
    
    run_steam_command "$cmd_string" "DepotDownloader installation"
    log_success "DepotDownloader installation finished."
fi

# ----------------------------
# Game Installation via SteamCMD
# ----------------------------
if [ "$DEPOTDOWNLOADER" != "1" ]; then
    log_info "Installing $GAME_NAME via SteamCMD..."
    mkdir -p "$STEAMCMD_DIR" "$HOME/steamapps"

    run_or_fail "Download SteamCMD" \
        download_with_retry \
        "http://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
        "/tmp/steamcmd.tar.gz" \
        3 \
        "SteamCMD archive"
    
    run_or_fail "Extract SteamCMD" tar -xzf /tmp/steamcmd.tar.gz -C "$STEAMCMD_DIR"

    cd "$STEAMCMD_DIR"

    # Build SteamCMD command array
    declare -a steam_cmd=(
        "./steamcmd.sh"
        "+force_install_dir" "$HOME"
        "+login" "$STEAM_USER"
    )
    
    if [[ -n "$STEAM_PASS" ]]; then
        steam_cmd+=("$STEAM_PASS")
    fi
    
    if [[ -n "$STEAM_AUTH" ]]; then
        steam_cmd+=("$STEAM_AUTH")
    fi
    
    if [[ "${WINDOWS_INSTALL:-0}" == "1" ]]; then
        steam_cmd+=("+@sSteamCmdForcePlatformType" "windows")
    fi
    
    steam_cmd+=("+app_update" "$STEAM_APPID" "+app_update" "1007")
    
    if [[ -n "${STEAM_BETAID:-}" ]]; then
        steam_cmd+=("-beta" "$STEAM_BETAID")
    fi
    
    if [[ -n "${STEAM_BETAPASS:-}" ]]; then
        steam_cmd+=("-betapassword" "$STEAM_BETAPASS")
    fi
    
    # Add install flags if provided
    if [[ -n "${INSTALL_FLAGS:-}" ]]; then
        read -ra flags <<< "$INSTALL_FLAGS"
        steam_cmd+=("${flags[@]}")
    fi
    
    steam_cmd+=("validate" "+quit")

    # Convert array to string for run_steam_command
    cmd_string=""
    printf -v cmd_string '%q ' "${steam_cmd[@]}"
    
    run_steam_command "$cmd_string" "SteamCMD installation"
    log_success "SteamCMD installation finished."
fi

# ----------------------------
# Steam Libraries Setup
# ----------------------------
log_info "Setting up Steam libraries..."
mkdir -p "$HOME/.steam/sdk32" "$HOME/.steam/sdk64"

if [ -f "$STEAMCMD_DIR/linux32/steamclient.so" ]; then
    if cp -v "$STEAMCMD_DIR/linux32/steamclient.so" "$HOME/.steam/sdk32/steamclient.so"; then
        log_success "32-bit Steam library copied successfully"
    else
        log_warn "Failed to copy 32-bit Steam library"
    fi
else
    log_warn "32-bit Steam library not found"
fi

if [ -f "$STEAMCMD_DIR/linux64/steamclient.so" ]; then
    if cp -v "$STEAMCMD_DIR/linux64/steamclient.so" "$HOME/.steam/sdk64/steamclient.so"; then
        log_success "64-bit Steam library copied successfully"
    else
        log_warn "Failed to copy 64-bit Steam library"
    fi
else
    log_warn "64-bit Steam library not found"
fi

log_success "Steam libraries setup complete."

# ----------------------------
# Game-specific Hooks
# ----------------------------
log_info "Executing $GAME_NAME game-specific hooks..."
# <--- add game-specific commands here

# ----------------------------
# Config Setup
# ----------------------------
if [ "${CONFIG_INIT:-0}" -eq 1 ]; then
    if [ -f "$CONFIG_DIR/$CONFIG_FILE_NAME" ]; then
        log_success "$GAME_NAME $CONFIG_FILE_NAME found."
    else
        log_warn "$GAME_NAME $CONFIG_FILE_NAME not found. Fetching default..."
        mkdir -p "$CONFIG_DIR"
        
        run_or_fail "Download default $CONFIG_FILE_NAME" \
            download_with_retry \
            "$CONFIG_URL" \
            "$CONFIG_DIR/$CONFIG_FILE_NAME" \
            3 \
            "config file"
    fi
else
    log_info "Skipping config setup (CONFIG_INIT != 1)"
fi

# ----------------------------
# Final Verification
# ----------------------------
log_info "Running post-installation verification..."

# Check if Steam libraries were installed correctly
if [ ! -d "$HOME/.steam" ]; then
    log_warn "Steam directory not found - some games may not work correctly"
fi

# Check if basic Steam files exist
steam_files_found=0
if [ -f "$HOME/.steam/sdk32/steamclient.so" ]; then
    ((steam_files_found++))
fi
if [ -f "$HOME/.steam/sdk64/steamclient.so" ]; then
    ((steam_files_found++))
fi

if [ $steam_files_found -eq 0 ]; then
    log_warn "No Steam library files found - installation may be incomplete"
elif [ $steam_files_found -eq 1 ]; then
    log_warn "Only one Steam library found - some games may require both 32-bit and 64-bit libraries"
else
    log_success "Steam libraries installed correctly"
fi

# Check if game files were downloaded (safe version)
game_files=0
if command -v find >/dev/null 2>&1; then
    game_files=$(find "$HOME" -maxdepth 3 -type f \( -name "*.exe" -o -name "*.so" -o -name "*.bin" \) 2>/dev/null | wc -l || echo 0)
fi

if [ "$game_files" -gt 0 ]; then
    log_success "Found $game_files potential game executable files"
else
    log_warn "No executable files found - this is normal if STEAM_APPID was not set or installation failed"
fi

# Check permissions (non-fatal)
if [ ! -w "$HOME" ]; then
    log_warn "HOME directory is not writable - this may cause issues"
else
    log_success "HOME directory permissions are correct"
fi

# Check if SteamCMD was extracted successfully
if [ -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
    log_success "SteamCMD extracted successfully"
else
    log_warn "SteamCMD executable not found - installation may have failed"
fi

log_success "Installation verification completed"

# ----------------------------
# Done
# ----------------------------
log_info "$LINE"
log_success "$GAME_NAME installation completed successfully."
log_info "Installation log saved to: $INSTALL_LOG"
log_info "If you like my work -> https://donate.goover.dev"
log_info "$LINE"

exit 0