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

# Initialize log file
: > "$INSTALL_LOG"

# ----------------------------
# Colors
# ----------------------------
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
BLUE=$(tput setaf 4 2>/dev/null || echo "")
CYAN=$(tput setaf 6 2>/dev/null || echo "")
WHITE=$(tput setaf 7 2>/dev/null || echo "")
BOLD=$(tput bold 2>/dev/null || echo "")
NC=$(tput sgr0 2>/dev/null || echo "")

LINE="${BLUE}════════════════════════════════════════════════════════════════${NC}"

# ----------------------------
# Logging Functions
# ----------------------------
log_info()    { 
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${BLUE}[INFO]${NC} $*"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" >> "$INSTALL_LOG"
}
log_warn()    { 
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${YELLOW}[WARN]${NC} $*"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $*" >> "$INSTALL_LOG"
}
log_error()   { 
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${RED}[ERROR]${NC} $*" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" >> "$INSTALL_LOG"
}
log_success() { 
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${GREEN}[ OK ]${NC} $*"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ OK ] $*" >> "$INSTALL_LOG"
}

# Visual output functions (no timestamps for clean display)
print_step()    { 
    echo "${BLUE}│${NC}  ${CYAN}→${NC} $*"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [STEP] $*" >> "$INSTALL_LOG"
}
print_ok()      { 
    echo "${BLUE}│${NC}  ${GREEN}✓${NC} $*"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OK] $*" >> "$INSTALL_LOG"
}
print_warn()    { 
    echo "${BLUE}│${NC}  ${YELLOW}⚠${NC} $*"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $*" >> "$INSTALL_LOG"
}
print_error()   { 
    echo "${BLUE}│${NC}  ${RED}✗${NC} $*" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" >> "$INSTALL_LOG"
}

# Centered text in box (width=64 total, 62 between borders)
print_centered() {
    local text="$1"
    local color="$2"
    local box_width=62
    # Remove ANSI codes for length calculation
    local clean_text=$(printf "%s" "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local text_len=${#clean_text}
    local total_padding=$((box_width - text_len))
    local left_pad=$((total_padding / 2))
    local right_pad=$((total_padding - left_pad))
    printf "${BLUE}║${NC}%*s%s%s%s%*s${BLUE}║${NC}\n" "$left_pad" "" "$color" "$text" "${NC}" "$right_pad" ""
}

# Progress indication removed - causes issues with output redirection

# ----------------------------
# System Check Function
# ----------------------------
system_check() {
    local sys_info_file="$HOME/system_info.txt"
    
    echo ""
    echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    # "SYSTEM INFORMATION CHECK" = 24 chars, (64-24)/2 = 20 left, 20 right
    printf "${BLUE}║${NC}%20s${CYAN}${BOLD}%s${NC}%20s${BLUE}║${NC}\n" "" "SYSTEM INFORMATION CHECK" ""
    echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Initialize system info file
    {
        echo "=================================================================="
        echo "                   SYSTEM INFORMATION CHECK"
        echo "=================================================================="
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=================================================================="
        echo ""
    } > "$sys_info_file"
    
    # Kernel Information
    echo "${BLUE}┌─ ${CYAN}${BOLD}Kernel Information${NC}"
    if command -v uname &> /dev/null; then
        local kernel_name
        local kernel_version
        local distro_name="Unknown"
        local distro_version=""
        
        kernel_name=$(uname -s)
        kernel_version=$(uname -r)
        
        # Detect Linux distribution (pure bash, no external tools)
        if [[ -f /etc/os-release ]]; then
            # Modern standard (systemd-based distros, Alpine, etc.)
            while IFS='=' read -r key value; do
                value="${value%\"}"
                value="${value#\"}"
                case "$key" in
                    PRETTY_NAME) distro_name="$value" ;;
                    VERSION_ID) distro_version="$value" ;;
                esac
            done < /etc/os-release
        elif [[ -f /etc/lsb-release ]]; then
            # LSB-compliant distros
            while IFS='=' read -r key value; do
                value="${value%\"}"
                value="${value#\"}"
                case "$key" in
                    DISTRIB_DESCRIPTION) distro_name="$value" ;;
                    DISTRIB_RELEASE) distro_version="$value" ;;
                esac
            done < /etc/lsb-release
        elif [[ -f /etc/alpine-release ]]; then
            distro_name="Alpine Linux"
            distro_version=$(cat /etc/alpine-release 2>/dev/null)
        elif [[ -f /etc/debian_version ]]; then
            distro_name="Debian"
            distro_version=$(cat /etc/debian_version 2>/dev/null)
        elif [[ -f /etc/redhat-release ]]; then
            distro_name=$(cat /etc/redhat-release 2>/dev/null)
        elif [[ -f /etc/arch-release ]]; then
            distro_name="Arch Linux"
        elif [[ -f /etc/gentoo-release ]]; then
            distro_name=$(cat /etc/gentoo-release 2>/dev/null)
        elif [[ -f /etc/SuSE-release ]]; then
            distro_name=$(head -n1 /etc/SuSE-release 2>/dev/null)
        elif [[ -f /etc/issue ]]; then
            # Fallback to /etc/issue (strip escape sequences)
            distro_name=$(head -n1 /etc/issue 2>/dev/null | sed 's/\\[a-z]//g' | xargs)
        fi
        
        # Fallback if still unknown
        [[ "$distro_name" == "Unknown" || -z "$distro_name" ]] && distro_name="$kernel_name"
        
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Distro:  ${WHITE}${distro_name}${NC}"
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Kernel:  ${WHITE}${kernel_version}${NC}"
        {
            echo "KERNEL INFORMATION:"
            echo "  Distro:  ${distro_name}"
            echo "  Kernel:  ${kernel_version}"
            echo ""
        } >> "$sys_info_file"
    else
        echo "${BLUE}│${NC}  ${YELLOW}⚠${NC} Kernel information not available"
        echo "Kernel Information: Not available" >> "$sys_info_file"
        echo "" >> "$sys_info_file"
    fi
    echo "${BLUE}└─${NC}"
    
    # CPU Information
    echo ""
    echo "${BLUE}┌─ ${CYAN}${BOLD}CPU Information${NC}"
    if [[ -f /proc/cpuinfo ]]; then
        local cpu_model
        local cpu_cores
        cpu_model=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d':' -f2 | xargs)
        cpu_cores=$(grep -c "^processor" /proc/cpuinfo)
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Model:   ${WHITE}${cpu_model}${NC}"
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Cores:   ${WHITE}${cpu_cores}${NC}"
        {
            echo "CPU INFORMATION:"
            echo "  Model: ${cpu_model}"
            echo "  Cores: ${cpu_cores}"
            echo ""
        } >> "$sys_info_file"
    else
        echo "${BLUE}│${NC}  ${YELLOW}⚠${NC} CPU information not available"
        echo "CPU Information: Not available" >> "$sys_info_file"
        echo "" >> "$sys_info_file"
    fi
    echo "${BLUE}└─${NC}"
    
    # Virtualization Detection
    echo ""
    echo "${BLUE}┌─ ${CYAN}${BOLD}Virtualization${NC}"
    local virt_status="Unknown"
    if command -v systemd-detect-virt &> /dev/null; then
        virt_status=$(systemd-detect-virt 2>/dev/null || echo "none")
        if [[ "$virt_status" == "none" ]]; then
            echo "${BLUE}│${NC}  ${GREEN}✓${NC} Type:    ${GREEN}Bare Metal (No Virtualization)${NC}"
            virt_status="Bare Metal"
        else
            echo "${BLUE}│${NC}  ${GREEN}✓${NC} Type:    ${YELLOW}${virt_status}${NC}"
        fi
    elif [[ -f /proc/cpuinfo ]]; then
        if grep -qE "^flags.*hypervisor" /proc/cpuinfo; then
            echo "${BLUE}│${NC}  ${YELLOW}⚠${NC} Type:    ${YELLOW}Virtualized (hypervisor detected)${NC}"
            virt_status="Virtualized (hypervisor flag present)"
        else
            echo "${BLUE}│${NC}  ${GREEN}✓${NC} Type:    ${GREEN}Likely Bare Metal${NC}"
            virt_status="Likely Bare Metal"
        fi
    else
        echo "${BLUE}│${NC}  ${YELLOW}⚠${NC} Type:    ${YELLOW}Cannot determine${NC}"
    fi
    {
        echo "VIRTUALIZATION:"
        echo "  Type: ${virt_status}"
        echo ""
    } >> "$sys_info_file"
    echo "${BLUE}└─${NC}"
    
    # Memory (RAM) Information
    echo ""
    echo "${BLUE}┌─ ${CYAN}${BOLD}Memory (RAM)${NC}"
    if [[ -f /proc/meminfo ]]; then
        local total_ram_kb
        local total_ram_mb
        local total_ram_gb
        local available_ram_kb
        local available_ram_mb
        local available_ram_gb
        local used_ram_mb
        local ram_percent
        
        total_ram_kb=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
        total_ram_mb=$((total_ram_kb / 1024))
        # Pure bash decimal calculation (integer.decimal)
        total_ram_gb="$((total_ram_mb / 1024)).$((total_ram_mb * 100 / 1024 % 100))"
        
        available_ram_kb=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
        available_ram_mb=$((available_ram_kb / 1024))
        available_ram_gb="$((available_ram_mb / 1024)).$((available_ram_mb * 100 / 1024 % 100))"
        
        used_ram_mb=$((total_ram_mb - available_ram_mb))
        # Calculate percentage with one decimal place using pure bash
        ram_percent="$((used_ram_mb * 100 / total_ram_mb)).$((used_ram_mb * 1000 / total_ram_mb % 10))"
        
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Total:     ${WHITE}${total_ram_mb} MB${NC} ${BLUE}(${WHITE}${total_ram_gb} GB${BLUE})${NC}"
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Available: ${WHITE}${available_ram_mb} MB${NC} ${BLUE}(${WHITE}${available_ram_gb} GB${BLUE})${NC}"
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Used:      ${WHITE}${used_ram_mb} MB${NC}"
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Usage:     ${YELLOW}${ram_percent}%${NC}"
        
        {
            echo "MEMORY (RAM):"
            echo "  Total:     ${total_ram_mb} MB (${total_ram_gb} GB)"
            echo "  Available: ${available_ram_mb} MB (${available_ram_gb} GB)"
            echo "  Used:      ${used_ram_mb} MB"
            echo "  Usage:     ${ram_percent}%"
            echo ""
        } >> "$sys_info_file"
    else
        echo "${BLUE}│${NC}  ${YELLOW}⚠${NC} Memory information not available"
        echo "Memory (RAM): Not available" >> "$sys_info_file"
        echo "" >> "$sys_info_file"
    fi
    echo "${BLUE}└─${NC}"
    
    # Disk Space Information
    echo ""
    echo "${BLUE}┌─ ${CYAN}${BOLD}Disk Space (Home Directory)${NC}"
    if command -v df &> /dev/null; then
        local disk_info
        local disk_total
        local disk_used
        local disk_available
        local disk_percent
        
        disk_info=$(df -h "$HOME" 2>/dev/null | tail -n1)
        disk_total=$(echo "$disk_info" | awk '{print $2}')
        disk_used=$(echo "$disk_info" | awk '{print $3}')
        disk_available=$(echo "$disk_info" | awk '{print $4}')
        disk_percent=$(echo "$disk_info" | awk '{print $5}')
        
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Total:     ${WHITE}${disk_total}${NC}"
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Used:      ${WHITE}${disk_used}${NC} ${YELLOW}(${disk_percent})${NC}"
        echo "${BLUE}│${NC}  ${GREEN}✓${NC} Available: ${WHITE}${disk_available}${NC}"
        
        {
            echo "DISK SPACE (Home Directory):"
            echo "  Total:     ${disk_total}"
            echo "  Used:      ${disk_used} (${disk_percent})"
            echo "  Available: ${disk_available}"
            echo ""
        } >> "$sys_info_file"
    else
        echo "${BLUE}│${NC}  ${YELLOW}⚠${NC} Disk information not available"
        echo "Disk Space: Not available" >> "$sys_info_file"
        echo "" >> "$sys_info_file"
    fi
    echo "${BLUE}└─${NC}"
    
    echo ""
    {
        echo "=================================================================="
        echo "                  END OF SYSTEM INFORMATION"
        echo "=================================================================="
    } >> "$sys_info_file"
    
    # Only log to file, no screen output
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OK] System information saved to: ${sys_info_file}" >> "$INSTALL_LOG"
    echo ""
}

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
    if [[ ! "$path" =~ ^"$HOME" ]]; then
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
            echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] curl found but HTTPS support is missing" >> "$INSTALL_LOG"
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
    if [[ "${#missing[@]}" -gt 0 ]] || [[ "$curl_https_support" == "false" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] Attempting to install missing dependencies..." >> "$INSTALL_LOG"
        
        # Alpine Linux
        if command -v apk >/dev/null 2>&1; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Detected Alpine Linux, installing packages..." >> "$INSTALL_LOG"
            apk add --no-cache curl ca-certificates openssl tar wget 2>/dev/null || {
                echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Failed to install packages via apk" >> "$INSTALL_LOG"
                echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Missing required dependencies: ${missing[*]}" >> "$INSTALL_LOG"
                print_error "Failed to install packages via apk"
                exit 1
            }
        # Debian/Ubuntu
        elif command -v apt-get >/dev/null 2>&1; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Detected Debian/Ubuntu, installing packages..." >> "$INSTALL_LOG"
            export DEBIAN_FRONTEND=noninteractive
            apt-get update >/dev/null 2>&1 || true
            apt-get install -y curl ca-certificates openssl tar wget gnupg2 2>/dev/null || {
                echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Failed to install packages via apt-get" >> "$INSTALL_LOG"
                echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Missing required dependencies: ${missing[*]}" >> "$INSTALL_LOG"
                print_error "Failed to install packages via apt-get"
                exit 1
            }
            # Update CA certificates to ensure HTTPS works properly
            update-ca-certificates >/dev/null 2>&1 || true
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Unsupported Linux distribution" >> "$INSTALL_LOG"
            print_error "Unsupported Linux distribution"
            exit 1
        fi
        
        echo "$(date '+%Y-%m-%d %H:%M:%S') [OK] Dependencies installed successfully" >> "$INSTALL_LOG"
    fi
    
    # Re-check dependencies after installation
    missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [[ "${#missing[@]}" -gt 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Still missing dependencies after installation: ${missing[*]}" >> "$INSTALL_LOG"
        print_error "Still missing dependencies after installation: ${missing[*]}"
        exit 1
    fi
    
    # Check optional dependencies
    for dep in "${optional_deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] Optional dependency missing: $dep" >> "$INSTALL_LOG"
        fi
    done
    
    # Check system requirements
    if [[ "$(nproc 2>/dev/null || echo 1)" -lt 2 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] System has less than 2 CPU cores" >> "$INSTALL_LOG"
    fi
    
    local available_memory
    available_memory="$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)"
    if [[ "$available_memory" -lt 1024 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] Less than 1GB available memory" >> "$INSTALL_LOG"
    fi
    
    # Only log to file, no screen output
    echo "$(date '+%Y-%m-%d %H:%M:%S') [OK] All required dependencies found" >> "$INSTALL_LOG"
}

# ----------------------------
# Download with Retry Function
# ----------------------------
# shellcheck disable=SC2317  # Function is called later in script
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
        log_warn "HTTPS not supported by curl, will try HTTP fallback"
    fi
    
    for i in $(seq 1 "$retries"); do
        log_info "Downloading $desc (attempt $i/$retries)..."
        
        # Determine which URLs to try based on HTTPS support
        local urls_to_try=()
        if [[ "$url" =~ ^https:// ]]; then
            if [[ "$curl_supports_https" == "true" ]]; then
                # Try HTTPS first, then HTTP as fallback
                urls_to_try=("$url" "${url/https:/http:}")
            else
                # Only try HTTP if HTTPS is not supported
                urls_to_try=("${url/https:/http:}")
                log_warn "Using HTTP instead of HTTPS: ${url/https:/http:}"
            fi
        else
            # URL is already HTTP
            urls_to_try=("$url")
        fi
        
        local success=false
        local last_error=""
        
        for try_url in "${urls_to_try[@]}"; do
            # Use appropriate curl options based on protocol
            local curl_opts=(
                -fsSL
                --connect-timeout 30
                --max-time 300
                --retry 1
                --retry-delay 1
                --location
                -H "User-Agent: GameServer-Installer/1.0"
                -o "$output"
            )
            
            # Add protocol restrictions based on URL and support
            if [[ "$try_url" =~ ^https:// ]]; then
                curl_opts+=(--proto '=https' --tlsv1.2)
            else
                curl_opts+=(--proto '=http')
            fi
            
            last_error=$(curl "${curl_opts[@]}" "$try_url" 2>&1)
            if [[ "$?" -eq 0 ]]; then
                success=true
                break
            fi
        done
        
        if [[ "$success" == "true" ]]; then
            # Verify download
            if [[ -f "$output" ]]; then
                local file_size
                file_size="$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null || echo 0)"
                
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
        else
            if [[ -n "$last_error" ]]; then
                log_warn "Download failed: $last_error"
            fi
        fi
        
        if [[ "$i" -lt "$retries" ]]; then
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
    # Only log to file, no screen output
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Starting: $desc" >> "$INSTALL_LOG"
    
    if "$@" >> "$INSTALL_LOG" 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [OK] $desc" >> "$INSTALL_LOG"
    else
        local exit_code=$?
        echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $desc failed with exit code $exit_code" >> "$INSTALL_LOG"
        print_error "$desc failed (exit code $exit_code)"
        exit 1
    fi
}

# ----------------------------
# Cleanup Function
# ----------------------------
cleanup() {
    local exit_code=$?
    
    # Only log cleanup on errors
    if [[ "$exit_code" -ne 0 ]]; then
        log_info "Cleaning up temporary files..."
    fi
    
    # Remove temporary files
    rm -f /tmp/steamcmd.tar.gz /tmp/depotdownloader.zip /tmp/steam_output.log
    
    # Clean up any leftover processes
    pkill -f "steamcmd" 2>/dev/null || true
    pkill -f "DepotDownloader" 2>/dev/null || true
    
    # Clear sensitive variables
    unset STEAM_PASS STEAM_AUTH
    
    if [[ "$exit_code" -ne 0 ]]; then
        log_error "Script exited with error code $exit_code"
        log_info "Check the installation log at: $INSTALL_LOG"
    fi
    
    exit "$exit_code"
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
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Executing: $desc" >> "$INSTALL_LOG"
    
    local exit_code=0
    
    # Show progress output on screen while filtering sensitive data
    # SteamCMD outputs download progress which we want to show
    echo "${BLUE}│${NC}"
    "${cmd_array[@]}" 2>&1 | while IFS= read -r line; do
        # Log everything (filtered) to file
        echo "$line" | grep -v -iE "password|auth|token|secret" >> "$INSTALL_LOG" 2>/dev/null || true
        
        # Show progress lines on screen (update%, downloading, validating)
        if [[ "$line" =~ (Update|Downloading|Validating|progress|[0-9]+%) ]] || \
           [[ "$line" =~ ^\ *\[.*\] ]] || \
           [[ "$line" =~ "Success" ]] || \
           [[ "$line" =~ "Depot download" ]]; then
            # Filter out sensitive information before display
            local safe_line
            safe_line=$(echo "$line" | grep -v -iE "password|auth|token|secret|login")
            if [[ -n "$safe_line" ]]; then
                printf "${BLUE}│${NC}  ${WHITE}%s${NC}\n" "$safe_line"
            fi
        fi
    done
    exit_code=${PIPESTATUS[0]}
    echo "${BLUE}│${NC}"
    
    # Log results
    case "$exit_code" in
        0) echo "$(date '+%Y-%m-%d %H:%M:%S') [OK] $desc completed successfully" >> "$INSTALL_LOG" ;;
        2) 
            echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Steam login failed - check credentials" >> "$INSTALL_LOG"
            print_error "Steam login failed"
            ;;
        5) 
            echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] App not found or access denied for AppID: $STEAM_APPID" >> "$INSTALL_LOG"
            print_error "App not found (AppID: $STEAM_APPID)"
            ;;
        7) 
            echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] Steam is updating, please try again later" >> "$INSTALL_LOG"
            print_error "Steam is updating"
            ;;
        *) 
            if [[ "$exit_code" -ne 0 ]]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $desc exited with code $exit_code" >> "$INSTALL_LOG"
            fi
            ;;
    esac
    
    return "$exit_code"
}

# ----------------------------
# Start Script Output
# ----------------------------
clear
echo ""
echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
# "GAME INSTALLATION" = 17 chars, (64-17)/2 = 23 left, 24 right
printf "${BLUE}║${NC}%23s${YELLOW}${BOLD}%s${NC}%24s${BLUE}║${NC}\n" "" "GAME INSTALLATION" ""
# "${GAME_NAME}" - dynamisch berechnet
game_name_len=${#GAME_NAME}
game_left=$(( (64 - game_name_len) / 2 ))
game_right=$(( 64 - game_name_len - game_left ))
printf "${BLUE}║${NC}%*s${WHITE}%s${NC}%*s${BLUE}║${NC}\n" "$game_left" "" "${GAME_NAME}" "$game_right" ""
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ----------------------------
# System Check
# ----------------------------
system_check

# ----------------------------
# Pre-flight Checks
# ----------------------------
echo ""
echo "${BLUE}┌─ ${CYAN}${BOLD}Pre-flight Checks${NC}"
print_step "Validating environment..."
check_dependencies
print_step "Validating Steam App ID..."
validate_steam_appid
print_step "Validating configuration..."
validate_config_url
print_step "Validating Steam credentials..."
validate_steam_credentials
print_step "Validating paths..."
validate_path "$CONFIG_DIR" "CONFIG_DIR"
validate_path "$STEAMCMD_DIR" "STEAMCMD_DIR"
print_ok "All checks passed"
echo "${BLUE}└─${NC}"

# Check network connectivity
echo ""
echo "${BLUE}┌─ ${CYAN}${BOLD}Network Connectivity${NC}"
if ! curl -s --connect-timeout 10 --max-time 15 "https://steamcdn-a.akamaihd.net" >/dev/null 2>&1; then
    print_warn "HTTPS failed, trying HTTP..."
    if ! curl -s --connect-timeout 10 --max-time 15 "http://steamcdn-a.akamaihd.net" >/dev/null 2>&1; then
        print_error "Cannot reach Steam servers"
        echo "${BLUE}└─${NC}"
        exit 1
    else
        print_ok "HTTP connection verified"
    fi
else
    print_ok "HTTPS connection verified"
fi
echo "${BLUE}└─${NC}"

echo ""
if [[ "$STEAM_USER" == "anonymous" ]]; then
    echo "${BLUE}•${NC} ${YELLOW}Using anonymous Steam login${NC}"
else
    echo "${BLUE}•${NC} ${CYAN}Steam user:${NC} ${WHITE}$STEAM_USER${NC}"
fi

# ----------------------------
# Game Installation via DepotDownloader
# ----------------------------
if [[ "$DEPOTDOWNLOADER" == "1" ]]; then
    echo ""
    echo "${BLUE}┌─ ${CYAN}${BOLD}Game Installation (DepotDownloader)${NC}"
    print_step "Installing $GAME_NAME..."
    mkdir -p "$HOME/depotdownloader"
    cd "$HOME/depotdownloader"

    if [[ ! -f DepotDownloader ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Fetching DepotDownloader Linux binary..." >> "$INSTALL_LOG"
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
    print_ok "Installation finished"
    echo "${BLUE}└─${NC}"
fi

# ----------------------------
# Game Installation via SteamCMD
# ----------------------------
if [[ "$DEPOTDOWNLOADER" != "1" ]]; then
    echo ""
    echo "${BLUE}┌─ ${CYAN}${BOLD}Game Installation (SteamCMD)${NC}"
    print_step "Installing $GAME_NAME..."
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
    print_ok "Installation finished"
    echo "${BLUE}└─${NC}"
fi

# ----------------------------
# Steam Libraries Setup
# ----------------------------
echo ""
echo "${BLUE}┌─ ${CYAN}${BOLD}Steam Libraries Setup${NC}"
mkdir -p "$HOME/.steam/sdk32" "$HOME/.steam/sdk64"

if [[ -f "$STEAMCMD_DIR/linux32/steamclient.so" ]]; then
    if cp -v "$STEAMCMD_DIR/linux32/steamclient.so" "$HOME/.steam/sdk32/steamclient.so" >/dev/null 2>&1; then
        print_ok "32-bit Steam library copied"
    else
        print_warn "Failed to copy 32-bit library"
    fi
else
    print_warn "32-bit Steam library not found"
fi

if [[ -f "$STEAMCMD_DIR/linux64/steamclient.so" ]]; then
    if cp -v "$STEAMCMD_DIR/linux64/steamclient.so" "$HOME/.steam/sdk64/steamclient.so" >/dev/null 2>&1; then
        print_ok "64-bit Steam library copied"
    else
        print_warn "Failed to copy 64-bit library"
    fi
else
    print_warn "64-bit library not found"
fi
print_ok "Setup complete"
echo "${BLUE}└─${NC}"

# ----------------------------
# Game-specific Hooks
# ----------------------------
echo ""
echo "${BLUE}┌─ ${CYAN}${BOLD}Game-specific Hooks${NC}"
print_step "Executing custom commands..."
# <--- add game-specific commands here
print_ok "Hooks completed"
echo "${BLUE}└─${NC}"

# ----------------------------
# Config Setup
# ----------------------------
echo ""
echo "${BLUE}┌─ ${CYAN}${BOLD}Configuration Setup${NC}"
if [[ "${CONFIG_INIT:-0}" -eq 1 ]]; then
    if [[ -f "$CONFIG_DIR/$CONFIG_FILE_NAME" ]]; then
        print_ok "$CONFIG_FILE_NAME found"
    else
        print_warn "$CONFIG_FILE_NAME not found, fetching default..."
        mkdir -p "$CONFIG_DIR"
        
        run_or_fail "Download default $CONFIG_FILE_NAME" \
            download_with_retry \
            "$CONFIG_URL" \
            "$CONFIG_DIR/$CONFIG_FILE_NAME" \
            3 \
            "config file"
        print_ok "Configuration downloaded"
    fi
else
    print_step "Skipping (CONFIG_INIT != 1)"
fi
echo "${BLUE}└─${NC}"

# ----------------------------
# Final Verification
# ----------------------------
echo ""
echo "${BLUE}┌─ ${CYAN}${BOLD}Post-Installation Verification${NC}"

# Check if Steam libraries were installed correctly
if [[ ! -d "$HOME/.steam" ]]; then
    print_warn "Steam directory not found"
fi

# Check if basic Steam files exist
steam_files_found=0
if [[ -f "$HOME/.steam/sdk32/steamclient.so" ]]; then
    steam_files_found=$((steam_files_found + 1))
fi
if [[ -f "$HOME/.steam/sdk64/steamclient.so" ]]; then
    steam_files_found=$((steam_files_found + 1))
fi

if [[ "$steam_files_found" -eq 0 ]]; then
    print_warn "No Steam libraries found"
elif [[ "$steam_files_found" -eq 1 ]]; then
    print_warn "Only one Steam library found"
else
    print_ok "Steam libraries installed"
fi

# Check if game files were downloaded (safe version)
game_files=0
if command -v find >/dev/null 2>&1; then
    game_files="$(find "$HOME" -maxdepth 3 -type f \( -name "*.exe" -o -name "*.so" -o -name "*.bin" \) 2>/dev/null | wc -l || echo 0)"
fi

if [[ "$game_files" -gt 0 ]]; then
    print_ok "Found $game_files game files"
else
    print_warn "No executable files found"
fi

# Check permissions (non-fatal)
if [[ ! -w "$HOME" ]]; then
    print_warn "HOME directory not writable"
else
    print_ok "Permissions correct"
fi

# Check if SteamCMD was extracted successfully
if [[ -f "$STEAMCMD_DIR/steamcmd.sh" ]]; then
    print_ok "SteamCMD extracted successfully"
else
    print_warn "SteamCMD not found"
fi
print_ok "Verification completed"
echo "${BLUE}└─${NC}"

# ----------------------------
# Cleanup
# ----------------------------
echo ""
echo "${BLUE}┌─ ${CYAN}${BOLD}Cleanup${NC}"
print_step "Removing temporary files..."
rm -f /tmp/steamcmd.tar.gz /tmp/depotdownloader.zip /tmp/steam_output.log
print_ok "Cleanup complete"
echo "${BLUE}└─${NC}"

# ----------------------------
# Done
# ----------------------------
echo ""
echo "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
# "INSTALLATION COMPLETED" = 22 chars, (64-22)/2 = 21 left, 21 right
printf "${BLUE}║${NC}%21s${GREEN}${BOLD}%s${NC}%21s${BLUE}║${NC}\n" "" "INSTALLATION COMPLETED" ""
echo "${BLUE}╠════════════════════════════════════════════════════════════════╣${NC}"
# Ohne Emojis - nur ASCII für zuverlässige Ausrichtung
# Zeile 1: "  [OK] " = 7 Zeichen, Rest = 57
printf "${BLUE}║${NC}  ${GREEN}[OK]${NC} %-57s${BLUE}║${NC}\n" "${GAME_NAME} successfully installed"
# Zeile 2: "  Log: " = 7 Zeichen, Rest = 57
printf "${BLUE}║${NC}  Log: %-57s${BLUE}║${NC}\n" "$INSTALL_LOG"
# Zeile 3: "  Support: " = 11 Zeichen, Rest = 53
printf "${BLUE}║${NC}  Support: %-53s${BLUE}║${NC}\n" "https://donate.goover.dev"
echo "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

exit 0