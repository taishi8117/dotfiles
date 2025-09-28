#!/usr/bin/env bash
# lib/installers/tmux.sh - Install and configure Tmux with TPM

set -euo pipefail

# Source common functions
# shellcheck source=../common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Configuration
readonly TMUX_CONFIG_DIR="$DOTFILES_DIR/tmux"
readonly TPM_DIR="$HOME/.tmux/plugins/tpm"
readonly TMUX_CONF="$HOME/.tmux.conf"

# Check if tmux is installed
check_tmux_installed() {
    if ! command_exists "tmux"; then
        log_error "Tmux is not installed. Please install it first with system_deps."
        return 1
    fi

    local tmux_version
    tmux_version=$(tmux -V | cut -d' ' -f2)
    log_info "Found Tmux version: $tmux_version"

    # Check if version is recent enough (2.1+)
    local major minor
    major=$(echo "$tmux_version" | cut -d. -f1)
    minor=$(echo "$tmux_version" | cut -d. -f2)

    if [[ $major -lt 2 ]] || [[ $major -eq 2 && $minor -lt 1 ]]; then
        log_warn "Tmux version $tmux_version may be too old (recommend 2.1+)"
        log_warn "Some features may not work correctly"
    fi
}

# Backup existing tmux configuration
backup_existing_config() {
    log_info "Backing up existing tmux configuration..."

    # shellcheck source=../backup.sh
    source "$(dirname "${BASH_SOURCE[0]}")/../backup.sh"
    backup_tmux_files
}

# Install TPM (Tmux Plugin Manager)
install_tpm() {
    log_info "Installing TPM (Tmux Plugin Manager)..."

    if [[ -d "$TPM_DIR" ]]; then
        log_info "Updating existing TPM installation..."
        if git -C "$TPM_DIR" pull --quiet; then
            log_success "TPM updated successfully"
        else
            log_warn "Failed to update TPM (continuing with existing version)"
        fi
    else
        log_info "Installing TPM..."
        ensure_dir "$(dirname "$TPM_DIR")"

        if git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
            log_success "TPM installed successfully"
        else
            log_error "Failed to install TPM"
            return 1
        fi
    fi

    # Verify TPM installation
    if [[ -f "$TPM_DIR/tpm" ]]; then
        log_success "TPM installation verified"
    else
        log_error "TPM installation verification failed"
        return 1
    fi
}

# Link tmux configuration files
link_tmux_config() {
    log_info "Linking tmux configuration files..."

    # Backup existing tmux.conf if it's not a symlink
    if [[ -f "$TMUX_CONF" ]] && [[ ! -L "$TMUX_CONF" ]]; then
        backup_item "$TMUX_CONF" "tmux.conf"
    fi

    # Link main config file
    safe_symlink "$TMUX_CONFIG_DIR/tmux.conf" "$TMUX_CONF"

    # Create tmux directory and link additional config files
    ensure_dir "$HOME/.tmux"

    # Link additional config files if they exist
    for config_file in "$TMUX_CONFIG_DIR"/*.conf; do
        if [[ -f "$config_file" ]] && [[ "$(basename "$config_file")" != "tmux.conf" ]]; then
            local target="$HOME/.tmux/$(basename "$config_file")"
            safe_symlink "$config_file" "$target"
        fi
    done

    # Link utility scripts
    for script_file in "$TMUX_CONFIG_DIR"/*.sh; do
        if [[ -f "$script_file" ]] && [[ "$(basename "$script_file")" != "install.sh" ]]; then
            local target="$HOME/.tmux/$(basename "$script_file")"
            safe_symlink "$script_file" "$target"
            chmod +x "$target" 2>/dev/null || true
        fi
    done

    log_success "Tmux configuration files linked"
}

# Install TPM plugins
install_tpm_plugins() {
    log_info "Installing TPM plugins..."

    # Check if tmux server is running
    local tmux_running=false
    if tmux list-sessions &>/dev/null; then
        tmux_running=true
        log_debug "Tmux server is running"
    fi

    # Install plugins using TPM
    if [[ "$tmux_running" == "true" ]]; then
        # If tmux is running, use it directly
        if tmux run-shell "$TPM_DIR/bin/install_plugins" &>/dev/null; then
            log_success "TPM plugins installed via running session"
        else
            log_warn "Failed to install plugins via running session"
        fi
    else
        # Start a temporary tmux session to install plugins
        log_info "Starting temporary tmux session to install plugins..."

        # Create a temporary session
        if tmux new-session -d -s "__dotfiles_install_$$" &>/dev/null; then
            # Install plugins
            tmux run-shell -t "__dotfiles_install_$$" "$TPM_DIR/bin/install_plugins" &>/dev/null || true

            # Give it a moment to complete
            sleep 2

            # Kill the temporary session
            tmux kill-session -t "__dotfiles_install_$$" &>/dev/null || true

            log_success "TPM plugins installed via temporary session"
        else
            log_warn "Failed to create temporary tmux session"
            log_info "Plugins will be installed on first tmux start"
        fi
    fi
}

# Verify tmux configuration
verify_tmux_config() {
    log_info "Verifying tmux configuration..."

    # Test tmux config syntax
    if tmux source-file "$TMUX_CONF" &>/dev/null; then
        log_success "Tmux configuration syntax is valid"
    else
        log_warn "Tmux configuration syntax check failed"
        log_warn "Configuration may still work, check manually with: tmux source-file ~/.tmux.conf"
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying tmux installation..."

    # Check config file link
    if [[ ! -L "$TMUX_CONF" ]] || [[ "$(readlink "$TMUX_CONF")" != "$TMUX_CONFIG_DIR/tmux.conf" ]]; then
        log_error "Tmux configuration not properly linked"
        return 1
    fi

    # Check TPM installation
    if [[ ! -f "$TPM_DIR/tpm" ]]; then
        log_error "TPM not properly installed"
        return 1
    fi

    log_success "Tmux installation verification passed"
    return 0
}

# Show TPM key bindings and usage info
show_tpm_info() {
    echo
    log_info "=== TPM (Tmux Plugin Manager) Usage ==="
    log_info "• Install plugins: prefix + I"
    log_info "• Update plugins: prefix + U"
    log_info "• Remove plugins: prefix + alt + u"
    log_info "• Reload tmux config: prefix + r"
    echo
    log_info "Default prefix key is Ctrl-b (unless changed in config)"
}

# Show post-installation notes
show_notes() {
    echo
    log_info "=== Tmux Installation Complete ==="
    log_info "• TPM (Tmux Plugin Manager) installed"
    log_info "• Configuration files linked"
    log_info "• Plugins installed/will install on first start"

    show_tpm_info

    log_info "Next steps:"
    log_info "• Run 'tmux' to start your first session"
    log_info "• Use 'tmux ls' to list sessions"
    log_info "• Use 'tmux attach' to attach to existing session"
    log_info "• Press prefix + ? for help (default prefix: Ctrl-b)"
}

# Check if running inside tmux
check_tmux_session() {
    if [[ -n "${TMUX:-}" ]]; then
        log_warn "You are currently inside a tmux session"
        log_warn "Some configuration changes may require restarting tmux"
        return 0
    fi
    return 1
}

# Main installation function
main() {
    log_info "=== Installing Tmux with TPM ==="

    # Pre-installation checks
    check_tmux_installed || return 1

    # Check if we're inside tmux
    check_tmux_session

    # Backup existing configuration
    backup_existing_config

    # Install TPM
    install_tpm || return 1

    # Link configuration files
    link_tmux_config || return 1

    # Verify configuration syntax
    verify_tmux_config

    # Install TPM plugins
    install_tpm_plugins

    # Verify installation
    verify_installation || return 1

    # Show completion notes
    show_notes

    log_success "Tmux installation completed successfully!"
    return 0
}

# Run main function
main "$@"