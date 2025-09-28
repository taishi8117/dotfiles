#!/usr/bin/env bash
# lib/common.sh - Shared functions and utilities

set -euo pipefail
IFS=$'\n\t'

# Global variables
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LOG_FILE="${LOG_FILE:-$HOME/.dotfiles-install.log}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)}"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Logging functions
log() {
    local level="$1"
    shift
    local timestamp="$(date +'%Y-%m-%d %H:%M:%S')"
    local message="[$timestamp] [$level] $*"

    case "$level" in
        "ERROR")
            echo -e "${RED}❌ $*${NC}" >&2
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  $*${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $*${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ $*${NC}"
            ;;
        "DEBUG")
            echo -e "${PURPLE}🔍 $*${NC}"
            ;;
        *)
            echo -e "${WHITE}$*${NC}"
            ;;
    esac

    echo "$message" >> "$LOG_FILE"
}

log_error() { log "ERROR" "$@"; }
log_warn() { log "WARN" "$@"; }
log_info() { log "INFO" "$@"; }
log_success() { log "SUCCESS" "$@"; }
log_debug() { log "DEBUG" "$@"; }

# Error handling
error_handler() {
    local exit_code=$1
    local line_num=$2
    log_error "Script failed at line $line_num with exit code $exit_code"
    log_error "Check $LOG_FILE for details"
    exit $exit_code
}

# Set error trap
trap 'error_handler $? $LINENO' ERR

# OS Detection
detect_os() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        OS_ID="$ID"
        OS_VERSION="$VERSION_ID"
        OS_NAME="$PRETTY_NAME"
    else
        log_error "Cannot detect operating system"
        return 1
    fi

    log_info "Detected OS: $OS_NAME"

    if [[ "$OS_ID" != "ubuntu" ]]; then
        log_warn "This script is optimized for Ubuntu. Detected: $OS_ID"
        log_warn "Proceed with caution or consider using a supported OS"
    fi

    # Check Ubuntu version
    if [[ "$OS_ID" == "ubuntu" ]]; then
        case "$OS_VERSION" in
            "20.04"|"22.04"|"24.04")
                log_info "Ubuntu version $OS_VERSION is supported"
                ;;
            *)
                log_warn "Ubuntu version $OS_VERSION is not tested"
                ;;
        esac
    fi
}

# Docker detection
is_docker() {
    [[ -f /.dockerenv ]] || grep -q docker /proc/1/cgroup 2>/dev/null
}

# Check if running in Docker
detect_docker() {
    if is_docker; then
        log_info "Running inside Docker container"
        DOTFILES_DOCKER=1
        export DOTFILES_DOCKER
    else
        log_info "Running on host system"
        DOTFILES_DOCKER=0
        export DOTFILES_DOCKER
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if package is installed (Ubuntu/Debian)
package_installed() {
    dpkg -l "$1" &>/dev/null
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    [[ -d "$dir" ]] || mkdir -p "$dir"
}

# Safe symlink creation
safe_symlink() {
    local target="$1"
    local link="$2"

    # Remove existing file/link if different
    if [[ -e "$link" ]] || [[ -L "$link" ]]; then
        if [[ ! -L "$link" ]] || [[ "$(readlink "$link")" != "$target" ]]; then
            log_debug "Removing existing $link"
            rm -f "$link"
        else
            log_debug "Link already correct: $link -> $target"
            return 0
        fi
    fi

    # Create parent directory if needed
    ensure_dir "$(dirname "$link")"

    # Create symlink
    ln -sfn "$target" "$link"
    log_debug "Created symlink: $link -> $target"
}

# Backup file or directory
backup_item() {
    local item="$1"
    local backup_name="${2:-$(basename "$item")}"

    if [[ -e "$item" ]]; then
        ensure_dir "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$backup_name.$(date +%H%M%S)"
        cp -r "$item" "$backup_path"
        log_info "Backed up $item to $backup_path"
        return 0
    else
        log_debug "Nothing to backup: $item does not exist"
        return 1
    fi
}

# Install package if not already installed
install_package() {
    local package="$1"

    if package_installed "$package"; then
        log_debug "$package is already installed"
        return 0
    fi

    log_info "Installing $package..."
    if sudo apt-get install -y "$package"; then
        log_success "$package installed successfully"
    else
        log_error "Failed to install $package"
        return 1
    fi
}

# Update package lists if needed (Ubuntu/Debian)
update_package_lists() {
    local update_stamp="/var/lib/apt/periodic/update-success-stamp"

    # Update if stamp is older than 24 hours or doesn't exist
    if [[ ! -f "$update_stamp" ]] || [[ $(find "$update_stamp" -mtime +1 2>/dev/null) ]]; then
        log_info "Updating package lists..."
        sudo apt-get update || log_warn "Package list update failed"
    else
        log_debug "Package lists are recent, skipping update"
    fi
}

# Clone or update git repository
clone_or_update_repo() {
    local url="$1"
    local destination="$2"
    local branch="${3:-main}"

    if [[ -d "$destination/.git" ]]; then
        log_info "Updating repository at $destination"
        git -C "$destination" fetch origin
        git -C "$destination" reset --hard "origin/$branch"
    else
        log_info "Cloning $url to $destination"
        ensure_dir "$(dirname "$destination")"
        git clone --branch "$branch" "$url" "$destination"
    fi
}

# Check if we're running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warn "This script should not be run as root"
        log_warn "Please run as a regular user with sudo access"
        return 1
    fi
}

# Check sudo access
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log_info "This script requires sudo access"
        log_info "Please enter your password when prompted"
        sudo -v || {
            log_error "Sudo access required but not available"
            return 1
        }
    fi
}

# Initialize logging
init_logging() {
    # Ensure log directory exists
    ensure_dir "$(dirname "$LOG_FILE")"

    # Start logging session
    log_info "=== Dotfiles installation started ==="
    log_info "Dotfiles directory: $DOTFILES_DIR"
    log_info "Log file: $LOG_FILE"
    log_info "Backup directory: $BACKUP_DIR"
}

# Cleanup function
cleanup() {
    log_info "=== Installation completed ==="
}

# Set cleanup trap
trap cleanup EXIT

# Show progress
show_progress() {
    local current="$1"
    local total="$2"
    local component="$3"

    local percent=$((current * 100 / total))
    local filled=$((percent / 5))
    local empty=$((20 - filled))

    printf "\r${BLUE}[%s%s] %d%% - %s${NC}" \
        "$(printf '%*s' $filled | tr ' ' '=')" \
        "$(printf '%*s' $empty | tr ' ' ' ')" \
        $percent \
        "$component"

    if [[ $current -eq $total ]]; then
        echo
    fi
}

# Export functions for use in other scripts
export -f log log_error log_warn log_info log_success log_debug
export -f command_exists package_installed ensure_dir safe_symlink
export -f backup_item install_package clone_or_update_repo
export -f is_docker detect_docker detect_os
export -f check_not_root check_sudo update_package_lists
export -f show_progress

# Export variables
export DOTFILES_DIR LOG_FILE BACKUP_DIR
export RED GREEN YELLOW BLUE PURPLE CYAN WHITE NC