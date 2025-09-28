#!/usr/bin/env bash
# lib/installers/zsh.sh - Install and configure Zsh with zinit

set -euo pipefail

# Source common functions
# shellcheck source=../common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Configuration
readonly ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
readonly ZSH_CONFIG_DIR="$DOTFILES_DIR/zsh"

# Check if zsh is installed
check_zsh_installed() {
    if ! command_exists "zsh"; then
        log_error "Zsh is not installed. Please install it first with system_deps."
        return 1
    fi

    local zsh_version
    zsh_version=$(zsh --version | cut -d' ' -f2)
    log_info "Found Zsh version: $zsh_version"
}

# Install or update zinit
install_zinit() {
    log_info "Setting up zinit plugin manager..."

    if [[ -d "$ZINIT_HOME" ]]; then
        log_info "Updating existing zinit installation..."
        if git -C "$ZINIT_HOME" pull --quiet; then
            log_success "Zinit updated successfully"
        else
            log_warn "Failed to update zinit (continuing with existing version)"
        fi
    else
        log_info "Installing zinit..."
        ensure_dir "$(dirname "$ZINIT_HOME")"

        if git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"; then
            log_success "Zinit installed successfully"
        else
            log_error "Failed to install zinit"
            return 1
        fi
    fi

    # Verify zinit installation
    if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
        log_success "Zinit installation verified"
    else
        log_error "Zinit installation verification failed"
        return 1
    fi
}

# Backup existing zsh configuration
backup_existing_config() {
    log_info "Backing up existing zsh configuration..."

    # shellcheck source=../backup.sh
    source "$(dirname "${BASH_SOURCE[0]}")/../backup.sh"
    backup_zsh_files
}

# Link zsh configuration files
link_zsh_config() {
    log_info "Linking zsh configuration files..."

    # Link main config files
    safe_symlink "$ZSH_CONFIG_DIR/.zshrc" "$HOME/.zshrc"
    safe_symlink "$ZSH_CONFIG_DIR/.zshenv" "$HOME/.zshenv"

    log_success "Zsh configuration files linked"
}

# Set zsh as default shell
set_default_shell() {
    local zsh_path
    zsh_path=$(which zsh)

    # Skip in Docker containers
    if [[ "$DOTFILES_DOCKER" == "1" ]]; then
        log_info "Docker mode: Skipping default shell change"
        return 0
    fi

    if [[ "$SHELL" == "$zsh_path" ]]; then
        log_info "Zsh is already the default shell"
        return 0
    fi

    log_info "Setting zsh as default shell..."

    # Check if zsh is in /etc/shells
    if ! grep -q "^$zsh_path$" /etc/shells; then
        log_info "Adding zsh to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Change default shell
    if chsh -s "$zsh_path"; then
        log_success "Default shell changed to zsh"
        log_info "Please log out and log back in for the change to take effect"
    else
        log_warn "Failed to change default shell (you may need to do this manually)"
        log_info "Run: chsh -s $zsh_path"
    fi
}

# Install zinit plugins
install_plugins() {
    log_info "Installing zinit plugins..."

    # Create a minimal zsh session to install plugins
    local temp_zshrc="/tmp/.zshrc_temp_$$"
    cat > "$temp_zshrc" << 'EOF'
# Temporary zshrc for plugin installation
export ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"

# Load zinit
if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
    source "$ZINIT_HOME/zinit.zsh"

    # Install plugins (same as in main config)
    zinit light zsh-users/zsh-syntax-highlighting
    zinit light zsh-users/zsh-autosuggestions
    zinit light djui/alias-tips
    zinit snippet OMZ::lib/completion.zsh
    zinit snippet OMZ::lib/git.zsh
    zinit snippet OMZ::plugins/colorize/colorize.plugin.zsh
    zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
    zinit snippet OMZ::plugins/git/git.plugin.zsh
    zinit snippet OMZ::plugins/virtualenv/virtualenv.plugin.zsh
    zinit snippet OMZ::plugins/docker/docker.plugin.zsh

    # Install all plugins
    zinit update --all >/dev/null 2>&1 || true
fi
EOF

    # Run zsh with temporary config to install plugins
    if ZDOTDIR=/tmp zsh -c "source '$temp_zshrc'" 2>/dev/null; then
        log_success "Zinit plugins installed"
    else
        log_warn "Plugin installation may have failed (plugins will install on first shell start)"
    fi

    # Clean up
    rm -f "$temp_zshrc"
}

# Verify zsh installation
verify_installation() {
    log_info "Verifying zsh installation..."

    # Check zinit
    if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
        log_error "Zinit installation verification failed"
        return 1
    fi

    # Check config files
    if [[ ! -L "$HOME/.zshrc" ]] || [[ ! -L "$HOME/.zshenv" ]]; then
        log_error "Zsh configuration files not properly linked"
        return 1
    fi

    # Verify links point to correct location
    if [[ "$(readlink "$HOME/.zshrc")" != "$ZSH_CONFIG_DIR/.zshrc" ]]; then
        log_error ".zshrc link is incorrect"
        return 1
    fi

    if [[ "$(readlink "$HOME/.zshenv")" != "$ZSH_CONFIG_DIR/.zshenv" ]]; then
        log_error ".zshenv link is incorrect"
        return 1
    fi

    log_success "Zsh installation verification passed"
    return 0
}

# Test zsh configuration
test_zsh_config() {
    log_info "Testing zsh configuration..."

    # Test that zsh can load the configuration without errors
    if zsh -c "source ~/.zshrc; echo 'Zsh config loaded successfully'" >/dev/null 2>&1; then
        log_success "Zsh configuration test passed"
    else
        log_warn "Zsh configuration test failed (may work after first interactive start)"
    fi
}

# Show post-installation notes
show_notes() {
    echo
    log_info "=== Zsh Installation Complete ==="
    log_info "• Zinit plugin manager installed"
    log_info "• Configuration files linked"

    if [[ "$DOTFILES_DOCKER" == "0" ]]; then
        if [[ "$SHELL" != "$(which zsh)" ]]; then
            log_info "• To complete setup, run: exec zsh"
        else
            log_info "• Restart your shell to see changes"
        fi
    else
        log_info "• In Docker: start zsh with 'zsh' command"
    fi

    log_info "• Plugins will auto-install on first zsh start"
    log_info "• Run 'zinit update' to update plugins later"
}

# Main installation function
main() {
    log_info "=== Installing Zsh with Zinit ==="

    # Pre-installation checks
    check_zsh_installed || return 1

    # Backup existing configuration
    backup_existing_config

    # Install zinit
    install_zinit || return 1

    # Link configuration
    link_zsh_config || return 1

    # Set as default shell (skip in Docker)
    set_default_shell

    # Install plugins
    install_plugins

    # Verify installation
    verify_installation || return 1

    # Test configuration
    test_zsh_config

    # Show completion notes
    show_notes

    log_success "Zsh installation completed successfully!"
    return 0
}

# Run main function
main "$@"