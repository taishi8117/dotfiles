#!/usr/bin/env bash
# install.sh - Main dotfiles installer

set -euo pipefail
IFS=$'\n\t'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$SCRIPT_DIR"

# Source common functions
# shellcheck source=./lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# Default options
INSTALL_MODE="full"
DRY_RUN=false
DOCKER_MODE=false
COMPONENTS=()
REINSTALL_COMPONENT=""

# Available components
readonly AVAILABLE_COMPONENTS=(
    "system_deps"
    "zsh"
    "nvim"
    "tmux"
    "dev_tools"
    "docker"
    "tailscale"
)

# Help text
show_help() {
    cat << 'EOF'
Dotfiles Installation Script

USAGE:
    ./install.sh [OPTIONS]

OPTIONS:
    --full              Install all components (default)
    --minimal           Install only shell environment (zsh, tmux, nvim)
    --only COMPONENT    Install only specified component
    --reinstall COMP    Backup, cleanup, and reinstall component
    --docker            Docker mode (skip interactive/systemd operations)
    --dry-run           Show what would be done without making changes
    --list-backups      List available backups
    --restore DATE      Restore from backup (format: YYYYMMDD_HHMMSS)
    --help              Show this help message

COMPONENTS:
    system_deps         System packages (jq, httpie, ripgrep, etc.)
    zsh                 Zsh shell with zinit plugin manager
    nvim                Neovim with lazy.nvim plugin manager
    tmux                Tmux with TPM plugin manager
    dev_tools           Development tools (nvm, rust, go)
    docker              Docker and docker-compose
    tailscale           Tailscale VPN

EXAMPLES:
    ./install.sh                    # Full installation
    ./install.sh --minimal          # Shell environment only
    ./install.sh --only nvim        # Install only Neovim
    ./install.sh --reinstall zsh    # Reinstall zsh safely
    ./install.sh --docker --full    # Full install in Docker
    ./install.sh --dry-run          # Preview changes

NOTES:
    - Automatic backups are created before any destructive operations
    - All operations are idempotent (safe to run multiple times)
    - Use --docker flag when running inside containers
    - Logs are written to ~/.dotfiles-install.log

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --full)
                INSTALL_MODE="full"
                shift
                ;;
            --minimal)
                INSTALL_MODE="minimal"
                shift
                ;;
            --only)
                INSTALL_MODE="only"
                if [[ $# -lt 2 ]]; then
                    log_error "--only requires a component name"
                    show_help
                    exit 1
                fi
                COMPONENTS=("$2")
                shift 2
                ;;
            --reinstall)
                if [[ $# -lt 2 ]]; then
                    log_error "--reinstall requires a component name"
                    show_help
                    exit 1
                fi
                REINSTALL_COMPONENT="$2"
                shift 2
                ;;
            --docker)
                DOCKER_MODE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --list-backups)
                # shellcheck source=./lib/backup.sh
                source "$SCRIPT_DIR/lib/backup.sh"
                list_backups
                exit 0
                ;;
            --restore)
                if [[ $# -lt 2 ]]; then
                    log_error "--restore requires a backup date"
                    show_help
                    exit 1
                fi
                # shellcheck source=./lib/backup.sh
                source "$SCRIPT_DIR/lib/backup.sh"
                restore_from_backup "$2"
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Validate component name
validate_component() {
    local component="$1"
    local valid=false

    for available in "${AVAILABLE_COMPONENTS[@]}"; do
        if [[ "$component" == "$available" ]]; then
            valid=true
            break
        fi
    done

    if [[ "$valid" == "false" ]]; then
        log_error "Invalid component: $component"
        log_error "Available components: ${AVAILABLE_COMPONENTS[*]}"
        exit 1
    fi
}

# Determine components to install based on mode
set_components() {
    case "$INSTALL_MODE" in
        "full")
            if is_docker; then
                # Skip docker and tailscale in Docker containers
                COMPONENTS=("system_deps" "zsh" "nvim" "tmux" "dev_tools")
            else
                COMPONENTS=("${AVAILABLE_COMPONENTS[@]}")
            fi
            ;;
        "minimal")
            COMPONENTS=("system_deps" "zsh" "nvim" "tmux")
            ;;
        "only")
            # Components already set in parse_args
            validate_component "${COMPONENTS[0]}"
            ;;
    esac
}

# Check if installer exists for component
check_installer() {
    local component="$1"
    local installer="$SCRIPT_DIR/lib/installers/${component}.sh"

    if [[ ! -f "$installer" ]]; then
        log_error "Installer not found: $installer"
        return 1
    fi

    if [[ ! -x "$installer" ]]; then
        log_warn "Making installer executable: $installer"
        chmod +x "$installer"
    fi

    return 0
}

# Install a single component
install_component() {
    local component="$1"
    local installer="$SCRIPT_DIR/lib/installers/${component}.sh"

    log_info "Installing component: $component"

    if ! check_installer "$component"; then
        log_error "Cannot install $component: installer not found"
        return 1
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would execute: $installer"
        return 0
    fi

    # Set environment for installer
    export DOTFILES_DIR
    export DOTFILES_DOCKER="$([[ "$DOCKER_MODE" == "true" ]] && echo "1" || echo "0")"

    # Execute installer
    if bash "$installer"; then
        log_success "$component installed successfully"
        return 0
    else
        log_error "Failed to install $component"
        return 1
    fi
}

# Reinstall component (backup → cleanup → install)
reinstall_component() {
    local component="$1"

    log_info "Reinstalling component: $component"

    validate_component "$component"

    # Backup before cleanup
    # shellcheck source=./lib/backup.sh
    source "$SCRIPT_DIR/lib/backup.sh"
    backup_dotfiles "$component"

    # Run component cleanup if it exists
    local cleanup_script=""
    case "$component" in
        "zsh")
            cleanup_script="$SCRIPT_DIR/zsh/cleanup.sh"
            ;;
        "nvim")
            cleanup_script="$SCRIPT_DIR/nvim/cleanup.sh"
            ;;
        "tmux")
            cleanup_script="$SCRIPT_DIR/tmux/cleanup.sh"
            ;;
    esac

    if [[ -n "$cleanup_script" ]] && [[ -f "$cleanup_script" ]]; then
        log_info "Running cleanup for $component"
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would execute: $cleanup_script"
        else
            bash "$cleanup_script" || log_warn "Cleanup script failed (continuing anyway)"
        fi
    fi

    # Install component
    install_component "$component"
}

# Main installation flow
main() {
    log_info "🚀 Starting dotfiles installation"
    log_info "Mode: $INSTALL_MODE"
    log_info "Docker: $([[ "$DOCKER_MODE" == "true" ]] && echo "yes" || echo "no")"
    log_info "Dry run: $([[ "$DRY_RUN" == "true" ]] && echo "yes" || echo "no")"

    # Handle reinstall mode
    if [[ -n "$REINSTALL_COMPONENT" ]]; then
        reinstall_component "$REINSTALL_COMPONENT"
        return 0
    fi

    # System checks
    if [[ "$DRY_RUN" == "false" ]]; then
        check_not_root
        detect_os
        detect_docker

        # Override docker mode if detected
        if [[ "$DOTFILES_DOCKER" == "1" ]] && [[ "$DOCKER_MODE" == "false" ]]; then
            log_info "Docker detected, enabling Docker mode"
            DOCKER_MODE=true
        fi
    fi

    # Determine components to install
    set_components

    log_info "Components to install: ${COMPONENTS[*]}"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "=== DRY RUN MODE ==="
        for component in "${COMPONENTS[@]}"; do
            log_info "Would install: $component"
        done
        log_info "=== END DRY RUN ==="
        return 0
    fi

    # Install components
    local total=${#COMPONENTS[@]}
    local current=0
    local failed_components=()

    for component in "${COMPONENTS[@]}"; do
        ((current++))
        show_progress "$current" "$total" "$component"

        if install_component "$component"; then
            log_success "✅ $component completed ($current/$total)"
        else
            log_error "❌ $component failed ($current/$total)"
            failed_components+=("$component")
        fi
    done

    # Summary
    echo
    log_info "=== Installation Summary ==="
    log_info "Total components: $total"
    log_info "Successful: $((total - ${#failed_components[@]}))"

    if [[ ${#failed_components[@]} -gt 0 ]]; then
        log_error "Failed: ${#failed_components[@]} (${failed_components[*]})"
        log_error "Check $LOG_FILE for details"
        return 1
    else
        log_success "All components installed successfully! 🎉"
        log_info "Log file: $LOG_FILE"

        # Post-installation notes
        echo
        log_info "=== Next Steps ==="
        log_info "• Restart your shell or run: source ~/.zshrc"
        log_info "• Open neovim to install plugins automatically"
        log_info "• Open tmux to install plugins automatically"

        if [[ "$DOCKER_MODE" == "false" ]]; then
            log_info "• Consider adding your SSH key to Tailscale"
        fi

        return 0
    fi
}

# Initialize
init_logging

# Parse arguments and run
parse_args "$@"
main