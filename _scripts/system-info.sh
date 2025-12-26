#!/bin/bash
# ------------------------------------------------
# System Information Script
# License: AGPLv3
# Author: gOOvER (https://discord.goover.dev)
# Donate: https://donate.goover.dev
# ------------------------------------------------

set -euo pipefail

# ----------------------------
# Configuration
# ----------------------------
WASTEBIN_URL="https://wastebin.goover.dev"
OUTPUT_FILE="/tmp/system-info-report-$$.txt"
UPLOAD_TO_WASTEBIN=0

# ----------------------------
# Colors
# ----------------------------
RED=$(tput setaf 1 2>/dev/null || echo "")
GREEN=$(tput setaf 2 2>/dev/null || echo "")
YELLOW=$(tput setaf 3 2>/dev/null || echo "")
BLUE=$(tput setaf 4 2>/dev/null || echo "")
CYAN=$(tput setaf 6 2>/dev/null || echo "")
MAGENTA=$(tput setaf 5 2>/dev/null || echo "")
NC=$(tput sgr0 2>/dev/null || echo "")

# ----------------------------
# Optional Package Installation
# ----------------------------
OPTIONAL_PACKAGES_INSTALLED=0

check_and_offer_packages() {
    local missing_packages=()
    
    # Check for optional but useful tools
    command -v systemd-detect-virt >/dev/null 2>&1 || missing_packages+=("systemd (für Virtualisierungs-Erkennung)")
    command -v lshw >/dev/null 2>&1 || missing_packages+=("lshw (für Hardware-Details)")
    command -v dmidecode >/dev/null 2>&1 || missing_packages+=("dmidecode (für System-Informationen)")
    
    if [ ${#missing_packages[@]} -eq 0 ]; then
        return 0
    fi
    
    echo ""
    echo "${YELLOW}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo "${YELLOW}║  Optionale Pakete für erweiterte Informationen                                 ║${NC}"
    echo "${YELLOW}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "${CYAN}Folgende optionale Pakete sind nicht installiert:${NC}"
    for pkg in "${missing_packages[@]}"; do
        echo "  ${YELLOW}•${NC} $pkg"
    done
    echo ""
    echo "${CYAN}Das Script kann auch ohne diese Pakete ausgeführt werden.${NC}"
    echo "${CYAN}Mit diesen Paketen erhalten Sie jedoch detailli

ertere Informationen.${NC}"
    echo ""
    
    read -p "${BLUE}Möchten Sie die fehlenden Pakete jetzt installieren? (j/N): ${NC}" -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[JjYy]$ ]]; then
        echo ""
        echo "${CYAN}Installiere optionale Pakete...${NC}"
        
        # Detect package manager and install
        if command -v apt-get >/dev/null 2>&1; then
            echo "${BLUE}Verwende apt-get...${NC}"
            sudo apt-get update >/dev/null 2>&1 || true
            sudo apt-get install -y systemd lshw dmidecode 2>/dev/null || {
                echo "${YELLOW}Einige Pakete konnten nicht installiert werden (möglicherweise bereits vorhanden)${NC}"
            }
        elif command -v apk >/dev/null 2>&1; then
            echo "${BLUE}Verwende apk...${NC}"
            sudo apk add --no-cache systemd lshw dmidecode 2>/dev/null || {
                echo "${YELLOW}Einige Pakete konnten nicht installiert werden${NC}"
            }
        elif command -v yum >/dev/null 2>&1; then
            echo "${BLUE}Verwende yum...${NC}"
            sudo yum install -y systemd lshw dmidecode 2>/dev/null || {
                echo "${YELLOW}Einige Pakete konnten nicht installiert werden${NC}"
            }
        elif command -v dnf >/dev/null 2>&1; then
            echo "${BLUE}Verwende dnf...${NC}"
            sudo dnf install -y systemd lshw dmidecode 2>/dev/null || {
                echo "${YELLOW}Einige Pakete konnten nicht installiert werden${NC}"
            }
        else
            echo "${RED}Kein unterstützter Paketmanager gefunden.${NC}"
            echo "${YELLOW}Bitte installieren Sie die Pakete manuell.${NC}"
        fi
        
        OPTIONAL_PACKAGES_INSTALLED=1
        echo "${GREEN}Installation abgeschlossen.${NC}"
        echo ""
        sleep 2
    else
        echo ""
        echo "${CYAN}Fahre ohne Installation fort...${NC}"
        echo ""
        sleep 1
    fi
}

upload_to_wastebin() {
    local content="$1"
    
    if ! command -v curl >/dev/null 2>&1; then
        echo ""
        echo "${RED}Fehler: curl ist nicht installiert. Kann nicht zu Wastebin hochladen.${NC}"
        return 1
    fi
    
    echo ""
    echo "${CYAN}Lade Report zu Wastebin hoch...${NC}"
    
    # Create temporary file for JSON payload
    local temp_file="/tmp/wastebin-payload-$$.json"
    
    # Escape content for JSON (simple approach)
    local escaped_content
    escaped_content=$(echo "$content" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk '{printf "%s\\n", $0}' | sed 's/\\n$//')
    
    # Create JSON payload
    echo "{\"text\":\"${escaped_content}\",\"extension\":\"txt\"}" > "$temp_file"
    
    # Upload to Wastebin
    local response
    response=$(curl -s -X POST "${WASTEBIN_URL}/api/pastes" \
        -H "Content-Type: application/json" \
        -d @"$temp_file" 2>&1)
    
    local curl_exit=$?
    rm -f "$temp_file"
    
    if [ $curl_exit -eq 0 ]; then
        # Try to extract path from response
        local paste_path
        paste_path=$(echo "$response" | grep -oP '"path"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
        
        if [ -n "$paste_path" ]; then
            local paste_url="${WASTEBIN_URL}${paste_path}"
            echo ""
            echo "${GREEN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
            echo "${GREEN}║  Report erfolgreich hochgeladen!                                               ║${NC}"
            echo "${GREEN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
            echo ""
            echo "${CYAN}URL:${NC} ${YELLOW}${paste_url}${NC}"
            echo ""
            return 0
        else
            # Fallback: try to parse the raw response
            echo ""
            echo "${YELLOW}Upload-Antwort:${NC} $response"
            echo ""
            
            # Try alternate pattern
            local alt_path
            alt_path=$(echo "$response" | grep -o '/[a-zA-Z0-9_-]\+' | head -n1)
            if [ -n "$alt_path" ]; then
                local paste_url="${WASTEBIN_URL}${alt_path}"
                echo "${CYAN}URL:${NC} ${YELLOW}${paste_url}${NC}"
                echo ""
                return 0
            fi
            
            return 1
        fi
    else
        echo ""
        echo "${RED}Fehler beim Hochladen: $response${NC}"
        return 1
    fi
}

ask_for_upload() {
    if [ ! -t 0 ]; then
        # Non-interactive mode, skip
        return
    fi
    
    echo ""
    read -p "${BLUE}Möchten Sie den Report zu Wastebin (${WASTEBIN_URL}) hochladen? (j/N): ${NC}" -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[JjYy]$ ]]; then
        UPLOAD_TO_WASTEBIN=1
    fi
}

# ----------------------------
# Helper Functions
# ----------------------------
print_header() {
    local title="$1"
    echo ""
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${CYAN}  $title${NC}"
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_info() {
    local label="$1"
    local value="$2"
    printf "${BLUE}%-25s${NC} : ${GREEN}%s${NC}\n" "$label" "$value"
}

print_warn() {
    local label="$1"
    local value="$2"
    printf "${BLUE}%-25s${NC} : ${YELLOW}%s${NC}\n" "$label" "$value"
}

print_error() {
    local label="$1"
    local value="$2"
    printf "${BLUE}%-25s${NC} : ${RED}%s${NC}\n" "$label" "$value"
}

format_bytes() {
    local bytes=$1
    
    if [ "$bytes" -lt 1024 ]; then
        echo "${bytes} B"
    elif [ "$bytes" -lt 1048576 ]; then
        echo "$((bytes / 1024)) KB"
    elif [ "$bytes" -lt 1073741824 ]; then
        echo "$((bytes / 1024 / 1024)) MB"
    elif [ "$bytes" -lt 1099511627776 ]; then
        echo "$((bytes / 1024 / 1024 / 1024)) GB"
    else
        echo "$((bytes / 1024 / 1024 / 1024 / 1024)) TB"
    fi
}

get_uptime_formatted() {
    local uptime_seconds
    uptime_seconds=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 0)
    
    local days=$((uptime_seconds / 86400))
    local hours=$(( (uptime_seconds % 86400) / 3600 ))
    local minutes=$(( (uptime_seconds % 3600) / 60 ))
    
    if [ "$days" -gt 0 ]; then
        echo "${days}d ${hours}h ${minutes}m"
    elif [ "$hours" -gt 0 ]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

# ----------------------------
# System Information Functions
# ----------------------------

show_system_info() {
    print_header "SYSTEM INFORMATION"
    
    # Hostname
    local hostname
    hostname=$(hostname 2>/dev/null || echo "Unknown")
    print_info "Hostname" "$hostname"
    
    # Operating System
    if [ -f /etc/os-release ]; then
        local os_name os_version
        os_name=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d'"' -f2)
        print_info "Operating System" "$os_name"
        
        os_version=$(grep "^VERSION_ID=" /etc/os-release | cut -d'"' -f2 || echo "N/A")
        [ -n "$os_version" ] && print_info "OS Version" "$os_version"
    else
        print_info "Operating System" "Unknown"
    fi
    
    # Kernel
    local kernel
    kernel=$(uname -r 2>/dev/null || echo "Unknown")
    print_info "Kernel" "$kernel"
    
    # Architecture
    local arch
    arch=$(uname -m 2>/dev/null || echo "Unknown")
    print_info "Architecture" "$arch"
    
    # Uptime
    local uptime_str
    uptime_str=$(get_uptime_formatted)
    print_info "Uptime" "$uptime_str"
    
    # Current Date/Time
    local current_time
    current_time=$(date "+%Y-%m-%d %H:%M:%S %Z" 2>/dev/null || echo "Unknown")
    print_info "Current Time" "$current_time"
    
    # Load Average
    if [ -f /proc/loadavg ]; then
        local load_avg
        load_avg=$(awk '{print $1, $2, $3}' /proc/loadavg)
        print_info "Load Average" "$load_avg"
    fi
}

show_virtualization_info() {
    print_header "VIRTUALIZATION INFORMATION"
    
    local virt_type="None detected"
    local virt_details=""
    local detection_method=""
    
    # Check systemd-detect-virt (if available)
    if command -v systemd-detect-virt >/dev/null 2>&1; then
        local detect_virt
        detect_virt=$(systemd-detect-virt 2>/dev/null || echo "none")
        if [ "$detect_virt" != "none" ]; then
            virt_type="$detect_virt"
            detection_method="systemd-detect-virt"
        fi
    fi
    
    # Check DMI information (fallback method)
    if [ "$virt_type" = "None detected" ] && [ -r /sys/class/dmi/id/product_name ]; then
        local product_name
        product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "")
        if [ -n "$product_name" ]; then
            case "$product_name" in
                *VMware*) virt_type="VMware"; detection_method="DMI" ;;
                *VirtualBox*) virt_type="VirtualBox"; detection_method="DMI" ;;
                *KVM*) virt_type="KVM"; detection_method="DMI" ;;
                *QEMU*) virt_type="QEMU"; detection_method="DMI" ;;
                *Xen*) virt_type="Xen"; detection_method="DMI" ;;
                *Bochs*) virt_type="Bochs"; detection_method="DMI" ;;
            esac
            virt_details="$product_name"
        fi
    fi
    
    # Check for Hyper-V (fallback)
    if [ "$virt_type" = "None detected" ] && [ -r /sys/class/dmi/id/sys_vendor ]; then
        local sys_vendor
        sys_vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "")
        if [[ "$sys_vendor" == *"Microsoft"* ]]; then
            virt_type="Hyper-V"
            virt_details="Microsoft Hyper-V"
            detection_method="DMI"
        fi
    fi
    
    # Check /proc/cpuinfo for hypervisor flag (always available)
    if [ "$virt_type" = "None detected" ] && grep -q "^flags.*hypervisor" /proc/cpuinfo 2>/dev/null; then
        virt_type="Generic Hypervisor"
        detection_method="/proc/cpuinfo"
    fi
    
    # Check for container virtualization (always works)
    if [ -f /.dockerenv ]; then
        virt_type="Docker Container"
        detection_method="/.dockerenv"
    elif [ -f /run/.containerenv ]; then
        virt_type="Podman Container"
        detection_method="/run/.containerenv"
    elif [ -f /proc/1/cgroup ] && grep -q "docker" /proc/1/cgroup 2>/dev/null; then
        virt_type="Docker Container"
        detection_method="cgroup"
    elif [ -f /proc/1/cgroup ] && grep -q "lxc" /proc/1/cgroup 2>/dev/null; then
        virt_type="LXC Container"
        detection_method="cgroup"
    fi
    
    # Check virt-what only if available (optional)
    if [ "$virt_type" = "None detected" ] && command -v virt-what >/dev/null 2>&1; then
        local virt_what_output
        virt_what_output=$(virt-what 2>/dev/null | head -n1)
        if [ -n "$virt_what_output" ]; then
            virt_type="$virt_what_output"
            detection_method="virt-what"
        fi
    fi
    
    # Display results
    if [ "$virt_type" = "None detected" ]; then
        print_info "Virtualization" "Bare Metal (No virtualization detected)"
    else
        print_warn "Virtualization" "$virt_type"
        [ -n "$detection_method" ] && print_info "Detection Method" "$detection_method"
    fi
    
    [ -n "$virt_details" ] && print_info "System Product" "$virt_details"
    
    # Check if nested virtualization is enabled (for KVM)
    if [ "$virt_type" = "KVM" ] || [ "$virt_type" = "QEMU" ]; then
        if [ -f /sys/module/kvm_intel/parameters/nested ] || [ -f /sys/module/kvm_amd/parameters/nested ]; then
            local nested
            nested=$(cat /sys/module/kvm_intel/parameters/nested 2>/dev/null || cat /sys/module/kvm_amd/parameters/nested 2>/dev/null || echo "N")
            if [ "$nested" = "Y" ] || [ "$nested" = "1" ]; then
                print_info "Nested Virtualization" "Enabled"
            else
                print_info "Nested Virtualization" "Disabled"
            fi
        fi
    fi
    
    # Check CPU virtualization support
    if grep -qE "(vmx|svm)" /proc/cpuinfo 2>/dev/null; then
        local virt_tech
        if grep -q "vmx" /proc/cpuinfo; then
            virt_tech="Intel VT-x"
        elif grep -q "svm" /proc/cpuinfo; then
            virt_tech="AMD-V"
        fi
        print_info "CPU Virtualization" "$virt_tech (Available)"
    else
        print_info "CPU Virtualization" "Not available or disabled"
    fi
    
    # Hypervisor vendor
    if [ -r /sys/hypervisor/type ]; then
        local hypervisor_type
        hypervisor_type=$(cat /sys/hypervisor/type 2>/dev/null || echo "")
        [ -n "$hypervisor_type" ] && print_info "Hypervisor Type" "$hypervisor_type"
    fi
}

show_cpu_info() {
    print_header "CPU INFORMATION"
    
    if [ -f /proc/cpuinfo ]; then
        # CPU Model
        local cpu_model
        cpu_model=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d':' -f2 | xargs)
        [ -n "$cpu_model" ] && print_info "CPU Model" "$cpu_model"
        
        # CPU Cores
        local cpu_cores
        cpu_cores=$(nproc 2>/dev/null || grep -c "^processor" /proc/cpuinfo)
        print_info "CPU Cores" "$cpu_cores"
        
        # CPU MHz
        local cpu_mhz
        cpu_mhz=$(grep "cpu MHz" /proc/cpuinfo | head -n1 | cut -d':' -f2 | xargs)
        [ -n "$cpu_mhz" ] && print_info "CPU MHz" "${cpu_mhz} MHz"
        
        # CPU Cache
        local cpu_cache
        cpu_cache=$(grep "cache size" /proc/cpuinfo | head -n1 | cut -d':' -f2 | xargs)
        [ -n "$cpu_cache" ] && print_info "CPU Cache" "$cpu_cache"
    fi
    
    # CPU Usage
    if command -v top >/dev/null 2>&1; then
        local cpu_usage
        cpu_usage=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        if [ -n "$cpu_usage" ]; then
            # Remove decimal point for comparison
            local cpu_int=$(echo "$cpu_usage" | cut -d'.' -f1)
            if [ "$cpu_int" -gt 80 ]; then
                print_error "CPU Usage" "${cpu_usage}%"
            elif [ "$cpu_int" -gt 50 ]; then
                print_warn "CPU Usage" "${cpu_usage}%"
            else
                print_info "CPU Usage" "${cpu_usage}%"
            fi
        fi
    elif [ -f /proc/stat ]; then
        # Fallback: Calculate CPU usage from /proc/stat
        print_info "CPU Usage" "Berechnung über /proc/stat verfügbar"
    fi
}

show_memory_info() {
    print_header "MEMORY INFORMATION"
    
    if [ -f /proc/meminfo ]; then
        # Total Memory
        local mem_total mem_free mem_available mem_buffers mem_cached
        mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
        mem_free=$(awk '/MemFree/ {print $2}' /proc/meminfo)
        mem_available=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
        mem_buffers=$(awk '/^Buffers:/ {print $2}' /proc/meminfo)
        mem_cached=$(awk '/^Cached:/ {print $2}' /proc/meminfo)
        
        local mem_used=$((mem_total - mem_free - mem_buffers - mem_cached))
        local mem_percent=$((mem_used * 100 / mem_total))
        
        print_info "Total Memory" "$(format_bytes $((mem_total * 1024)))"
        print_info "Used Memory" "$(format_bytes $((mem_used * 1024)))"
        print_info "Free Memory" "$(format_bytes $((mem_free * 1024)))"
        print_info "Available Memory" "$(format_bytes $((mem_available * 1024)))"
        
        if [ "$mem_percent" -gt 90 ]; then
            print_error "Memory Usage" "${mem_percent}%"
        elif [ "$mem_percent" -gt 75 ]; then
            print_warn "Memory Usage" "${mem_percent}%"
        else
            print_info "Memory Usage" "${mem_percent}%"
        fi
        
        # Swap Information
        local swap_total swap_free
        swap_total=$(awk '/SwapTotal/ {print $2}' /proc/meminfo)
        swap_free=$(awk '/SwapFree/ {print $2}' /proc/meminfo)
        
        if [ "$swap_total" -gt 0 ]; then
            local swap_used=$((swap_total - swap_free))
            local swap_percent=$((swap_used * 100 / swap_total))
            
            echo ""
            print_info "Total Swap" "$(format_bytes $((swap_total * 1024)))"
            print_info "Used Swap" "$(format_bytes $((swap_used * 1024)))"
            
            if [ "$swap_percent" -gt 50 ]; then
                print_warn "Swap Usage" "${swap_percent}%"
            else
                print_info "Swap Usage" "${swap_percent}%"
            fi
        else
            echo ""
            print_info "Swap" "Not configured"
        fi
    fi
}

show_disk_info() {
    print_header "DISK INFORMATION"
    
    if command -v df >/dev/null 2>&1; then
        echo ""
        printf "${BLUE}%-20s %-10s %-10s %-10s %-8s %-s${NC}\n" "Filesystem" "Size" "Used" "Available" "Use%" "Mounted on"
        echo "${CYAN}────────────────────────────────────────────────────────────────────────────────${NC}"
        
        df -h | grep -E "^/dev/" | while read -r line; do
            local fs size used avail percent mount
            fs=$(echo "$line" | awk '{print $1}')
            size=$(echo "$line" | awk '{print $2}')
            used=$(echo "$line" | awk '{print $3}')
            avail=$(echo "$line" | awk '{print $4}')
            percent=$(echo "$line" | awk '{print $5}' | tr -d '%')
            mount=$(echo "$line" | awk '{print $6}')
            
            if [ "$percent" -gt 90 ]; then
                printf "${RED}%-20s %-10s %-10s %-10s %-8s %-s${NC}\n" "$fs" "$size" "$used" "$avail" "${percent}%" "$mount"
            elif [ "$percent" -gt 75 ]; then
                printf "${YELLOW}%-20s %-10s %-10s %-10s %-8s %-s${NC}\n" "$fs" "$size" "$used" "$avail" "${percent}%" "$mount"
            else
                printf "${GREEN}%-20s %-10s %-10s %-10s %-8s %-s${NC}\n" "$fs" "$size" "$used" "$avail" "${percent}%" "$mount"
            fi
        done
        
        # Disk I/O Statistics
        if [ -f /proc/diskstats ]; then
            echo ""
            print_info "Disk I/O" "Available in /proc/diskstats"
        fi
    fi
}

show_network_info() {
    print_header "NETWORK INFORMATION"
    
    # Network Interfaces
    if command -v ip >/dev/null 2>&1; then
        local interfaces
        interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -v "lo")
        
        for iface in $interfaces; do
            local ip_addr
            ip_addr=$(ip -4 addr show "$iface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "No IP")
            
            local state
            state=$(ip link show "$iface" | grep -oP '(?<=state )\w+' || echo "Unknown")
            
            echo ""
            print_info "Interface" "$iface"
            print_info "  IP Address" "$ip_addr"
            
            if [ "$state" = "UP" ]; then
                print_info "  State" "$state"
            else
                print_warn "  State" "$state"
            fi
            
            # MAC Address
            local mac
            mac=$(ip link show "$iface" | grep -oP '(?<=link/ether )[0-9a-f:]+' || echo "N/A")
            print_info "  MAC Address" "$mac"
            
            # RX/TX Statistics
            if [ -f "/sys/class/net/$iface/statistics/rx_bytes" ]; then
                local rx_bytes tx_bytes
                rx_bytes=$(cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null || echo 0)
                tx_bytes=$(cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null || echo 0)
                print_info "  RX" "$(format_bytes "$rx_bytes")"
                print_info "  TX" "$(format_bytes "$tx_bytes")"
            fi
        done
    fi
    
    # Default Gateway
    if command -v ip >/dev/null 2>&1; then
        echo ""
        local gateway
        gateway=$(ip route | grep default | awk '{print $3}' | head -n1)
        [ -n "$gateway" ] && print_info "Default Gateway" "$gateway"
    fi
    
    # DNS Servers
    if [ -f /etc/resolv.conf ]; then
        local dns_servers
        dns_servers=$(grep "^nameserver" /etc/resolv.conf | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')
        [ -n "$dns_servers" ] && print_info "DNS Servers" "$dns_servers"
    fi
}

show_process_info() {
    print_header "PROCESS INFORMATION"
    
    # Total Processes
    local total_procs
    total_procs=$(ps aux | wc -l)
    print_info "Total Processes" "$total_procs"
    
    # Running Processes
    local running_procs
    running_procs=$(ps aux | grep -c " R " || echo 0)
    print_info "Running Processes" "$running_procs"
    
    # Sleeping Processes
    local sleeping_procs
    sleeping_procs=$(ps aux | grep -c " S " || echo 0)
    print_info "Sleeping Processes" "$sleeping_procs"
    
    # Zombie Processes
    local zombie_procs
    zombie_procs=$(ps aux | grep -c " Z " || echo 0)
    if [ "$zombie_procs" -gt 0 ]; then
        print_warn "Zombie Processes" "$zombie_procs"
    else
        print_info "Zombie Processes" "$zombie_procs"
    fi
    
    # Top 5 CPU Processes
    echo ""
    print_info "Top 5 CPU Processes" ""
    echo "${CYAN}────────────────────────────────────────────────────────────────────────────────${NC}"
    ps aux --sort=-%cpu | head -n6 | tail -n5 | awk '{printf "  %s%-5s %-10s %-6s %s%s%s\n", "'$BLUE'", $2, $1, $3"%", "'$NC'", substr($0, index($0,$11)), "'$NC'"}'
    
    # Top 5 Memory Processes
    echo ""
    print_info "Top 5 Memory Processes" ""
    echo "${CYAN}────────────────────────────────────────────────────────────────────────────────${NC}"
    ps aux --sort=-%mem | head -n6 | tail -n5 | awk '{printf "  %s%-5s %-10s %-6s %s%s%s\n", "'$BLUE'", $2, $1, $4"%", "'$NC'", substr($0, index($0,$11)), "'$NC'"}'
}

show_user_info() {
    print_header "USER INFORMATION"
    
    # Current User
    local current_user
    current_user=$(whoami 2>/dev/null || echo "Unknown")
    print_info "Current User" "$current_user"
    
    # User ID
    local uid gid
    uid=$(id -u 2>/dev/null || echo "Unknown")
    gid=$(id -g 2>/dev/null || echo "Unknown")
    print_info "User ID (UID)" "$uid"
    print_info "Group ID (GID)" "$gid"
    
    # Logged in Users
    local logged_users
    logged_users=$(who | wc -l)
    print_info "Logged in Users" "$logged_users"
    
    # Last Login (only if 'last' command is available)
    if command -v last >/dev/null 2>&1; then
        local last_login
        last_login=$(last -n1 -R "$current_user" 2>/dev/null | head -n1 | awk '{print $4, $5, $6, $7}' || echo "")
        if [ -n "$last_login" ] && [ "$last_login" != "wtmp" ]; then
            print_info "Last Login" "$last_login"
        fi
    fi
}

show_service_info() {
    print_header "SERVICE INFORMATION"
    
    # Check for systemd
    if command -v systemctl >/dev/null 2>&1; then
        local failed_services
        failed_services=$(systemctl --failed --no-pager --no-legend | wc -l)
        
        if [ "$failed_services" -gt 0 ]; then
            print_warn "Failed Services" "$failed_services"
            echo ""
            print_info "Failed Services List" ""
            echo "${CYAN}────────────────────────────────────────────────────────────────────────────────${NC}"
            systemctl --failed --no-pager --no-legend | while read -r line; do
                echo "  ${RED}$line${NC}"
            done
        else
            print_info "Failed Services" "None"
        fi
        
        # Active Services
        local active_services
        active_services=$(systemctl list-units --type=service --state=running --no-pager --no-legend | wc -l)
        print_info "Active Services" "$active_services"
    else
        print_info "Service Manager" "systemd not available"
    fi
}

show_docker_info() {
    # Only show Docker info if Docker is installed
    if command -v docker >/dev/null 2>&1; then
        print_header "DOCKER INFORMATION"
        
        # Check if Docker daemon is running
        if ! docker ps >/dev/null 2>&1; then
            print_warn "Docker Status" "Daemon nicht erreichbar (läuft Docker?)"
            return
        fi
        
        # Docker Version
        local docker_version
        docker_version=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',' || echo "Unknown")
        print_info "Docker Version" "$docker_version"
        
        # Running Containers
        local running_containers
        running_containers=$(docker ps -q 2>/dev/null | wc -l || echo 0)
        print_info "Running Containers" "$running_containers"
        
        # Total Containers
        local total_containers
        total_containers=$(docker ps -aq 2>/dev/null | wc -l || echo 0)
        print_info "Total Containers" "$total_containers"
        
        # Images
        local total_images
        total_images=$(docker images -q 2>/dev/null | wc -l || echo 0)
        print_info "Total Images" "$total_images"
        
        # Volumes
        local total_volumes
        total_volumes=$(docker volume ls -q 2>/dev/null | wc -l || echo 0)
        print_info "Total Volumes" "$total_volumes"
        
        # Networks
        local total_networks
        total_networks=$(docker network ls -q 2>/dev/null | wc -l || echo 0)
        print_info "Total Networks" "$total_networks"
    fi
}

# ----------------------------
# Main Script
# ----------------------------

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --upload|-u)
            UPLOAD_TO_WASTEBIN=1
            shift
            ;;
        --no-upload)
            UPLOAD_TO_WASTEBIN=0
            shift
            ;;
        --help|-h)
            echo "System Information Script"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -u, --upload       Automatisch zu Wastebin hochladen"
            echo "  --no-upload        Nicht zu Wastebin hochladen (automatischer Modus)"
            echo "  -h, --help         Diese Hilfe anzeigen"
            echo ""
            exit 0
            ;;
        *)
            echo "Unbekannte Option: $1"
            echo "Verwenden Sie --help für Hilfe"
            exit 1
            ;;
    esac
done

# Function to generate the report
generate_report() {
    clear
    echo ""
    echo "${MAGENTA}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo "${MAGENTA}║                         SYSTEM INFORMATION REPORT                              ║${NC}"
    echo "${MAGENTA}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"

    # Check for optional packages (only if running interactively)
    if [ -t 0 ] && [ "$UPLOAD_TO_WASTEBIN" -eq 0 ]; then
        check_and_offer_packages
    fi

    show_system_info
    show_virtualization_info
    show_cpu_info
    show_memory_info
    show_disk_info
    show_network_info
    show_process_info
    show_user_info
    show_service_info
    show_docker_info

    print_header "REPORT COMPLETE"
    echo ""
    echo "${GREEN}Report generated at: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo "${BLUE}For support: https://discord.goover.dev${NC}"
    echo "${YELLOW}If you like this script: https://donate.goover.dev${NC}"
    echo ""
}

# Execute and capture output
if [ "$UPLOAD_TO_WASTEBIN" -eq 1 ]; then
    # Generate report and save to file
    generate_report 2>&1 | tee "$OUTPUT_FILE"
    
    # Upload to Wastebin
    if [ -f "$OUTPUT_FILE" ]; then
        # Strip color codes for upload
        sed -r "s/\x1B\[[0-9;]*[mK]//g" "$OUTPUT_FILE" > "${OUTPUT_FILE}.plain"
        upload_to_wastebin "$(cat "${OUTPUT_FILE}.plain")"
        rm -f "$OUTPUT_FILE" "${OUTPUT_FILE}.plain"
    fi
else
    # Just generate the report
    generate_report
    
    # Ask if user wants to upload (only in interactive mode)
    if [ -t 0 ]; then
        ask_for_upload
        
        if [ "$UPLOAD_TO_WASTEBIN" -eq 1 ]; then
            # Regenerate report without colors and upload
            echo ""
            echo "${CYAN}Generiere Report für Upload...${NC}"
            generate_report 2>&1 | sed -r "s/\x1B\[[0-9;]*[mK]//g" > "$OUTPUT_FILE"
            upload_to_wastebin "$(cat "$OUTPUT_FILE")"
            rm -f "$OUTPUT_FILE"
        fi
    fi
fi

exit 0
