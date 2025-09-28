#!/usr/bin/env bash
# lib/installers/tailscale.sh - Install and configure Tailscale

set -euo pipefail

# Source common functions
# shellcheck source=../common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Configuration
readonly TAILSCALE_GPG_KEY_URL="https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg"
readonly TAILSCALE_REPO_URL="https://pkgs.tailscale.com/stable/ubuntu"

# Check if we're running inside Docker
check_docker_environment() {
    if [[ "$DOTFILES_DOCKER" == "1" ]]; then
        log_info "Running inside Docker container - skipping Tailscale installation"
        return 1
    fi
    return 0
}

# Check if Tailscale is already installed
check_existing_tailscale() {
    if command_exists tailscale; then
        local tailscale_version
        tailscale_version=$(tailscale version | head -n1)
        log_info "Tailscale is already installed: $tailscale_version"

        # Check if Tailscale is running
        if systemctl is-active tailscaled &>/dev/null; then
            log_info "Tailscale daemon is running"
        else
            log_warn "Tailscale daemon is not running"
        fi

        # Check connection status
        local status
        status=$(tailscale status --json 2>/dev/null | jq -r '.BackendState' 2>/dev/null || echo "unknown")
        case "$status" in
            "Running")
                log_info "Tailscale is connected and running"
                ;;
            "NeedsLogin")
                log_warn "Tailscale needs authentication"
                ;;
            "Stopped")
                log_warn "Tailscale is stopped"
                ;;
            *)
                log_info "Tailscale status: $status"
                ;;
        esac

        return 0
    fi
    return 1
}

# Add Tailscale's package signing key
add_tailscale_gpg_key() {
    log_info "Adding Tailscale's package signing key..."

    # Create keyring directory
    ensure_dir "/etc/apt/keyrings"

    # Download and add GPG key
    if curl -fsSL "$TAILSCALE_GPG_KEY_URL" | sudo tee /etc/apt/keyrings/tailscale.gpg >/dev/null; then
        sudo chmod a+r /etc/apt/keyrings/tailscale.gpg
        log_success "Tailscale GPG key added"
    else
        log_error "Failed to add Tailscale GPG key"
        return 1
    fi
}

# Add Tailscale repository
add_tailscale_repository() {
    log_info "Adding Tailscale repository..."

    # Get OS information
    local os_codename
    os_codename=$(lsb_release -cs)

    # Add repository
    local repo_line="deb [signed-by=/etc/apt/keyrings/tailscale.gpg] $TAILSCALE_REPO_URL $os_codename main"

    if echo "$repo_line" | sudo tee /etc/apt/sources.list.d/tailscale.list > /dev/null; then
        log_success "Tailscale repository added"
    else
        log_error "Failed to add Tailscale repository"
        return 1
    fi

    # Update package lists
    update_package_lists
}

# Install Tailscale
install_tailscale() {
    log_info "Installing Tailscale..."

    if install_package "tailscale"; then
        log_success "Tailscale installed successfully"
    else
        log_error "Failed to install Tailscale"
        return 1
    fi
}

# Start and enable Tailscale service
start_tailscale_service() {
    log_info "Starting Tailscale service..."

    # Start Tailscale daemon
    if sudo systemctl start tailscaled; then
        log_success "Tailscale daemon started"
    else
        log_error "Failed to start Tailscale daemon"
        return 1
    fi

    # Enable Tailscale daemon to start on boot
    if sudo systemctl enable tailscaled; then
        log_success "Tailscale daemon enabled for startup"
    else
        log_warn "Failed to enable Tailscale daemon for startup"
    fi
}

# Check if Tailscale is authenticated
check_tailscale_auth() {
    local status
    status=$(tailscale status --json 2>/dev/null | jq -r '.BackendState' 2>/dev/null || echo "unknown")

    case "$status" in
        "Running")
            log_success "Tailscale is authenticated and connected"
            return 0
            ;;
        "NeedsLogin")
            log_info "Tailscale needs authentication"
            return 1
            ;;
        "Stopped")
            log_warn "Tailscale is stopped"
            return 1
            ;;
        *)
            log_warn "Tailscale status unknown: $status"
            return 1
            ;;
    esac
}

# Authenticate with Tailscale
authenticate_tailscale() {
    log_info "Tailscale authentication required..."

    # Check for auth key environment variable
    if [[ -n "${TAILSCALE_AUTH_KEY:-}" ]]; then
        log_info "Using auth key from environment variable"
        if tailscale up --authkey="$TAILSCALE_AUTH_KEY"; then
            log_success "Tailscale authenticated with auth key"
            return 0
        else
            log_error "Failed to authenticate with auth key"
            return 1
        fi
    fi

    # Check for auth key in a file
    local auth_key_file="$HOME/.tailscale-auth-key"
    if [[ -f "$auth_key_file" ]]; then
        local auth_key
        auth_key=$(cat "$auth_key_file")
        if [[ -n "$auth_key" ]]; then
            log_info "Using auth key from $auth_key_file"
            if tailscale up --authkey="$auth_key"; then
                log_success "Tailscale authenticated with auth key from file"
                return 0
            else
                log_error "Failed to authenticate with auth key from file"
                return 1
            fi
        fi
    fi

    # Interactive authentication
    log_info "Starting interactive authentication..."
    log_info "This will open a browser or provide a URL for authentication"

    if tailscale up; then
        log_success "Tailscale authentication completed"
        return 0
    else
        log_error "Tailscale authentication failed"
        return 1
    fi
}

# Configure Tailscale settings
configure_tailscale() {
    log_info "Configuring Tailscale settings..."

    # Enable auto-update (if supported)
    if tailscale set --auto-update 2>/dev/null; then
        log_info "Auto-update enabled"
    else
        log_debug "Auto-update not supported or already configured"
    fi

    # Set a hostname if not already set
    local current_hostname
    current_hostname=$(tailscale status --json 2>/dev/null | jq -r '.Self.HostName' 2>/dev/null || echo "")

    if [[ -z "$current_hostname" || "$current_hostname" == "null" ]]; then
        local desired_hostname
        desired_hostname=$(hostname -s)

        if [[ -n "$desired_hostname" ]]; then
            log_info "Setting Tailscale hostname to: $desired_hostname"
            if tailscale up --hostname="$desired_hostname" 2>/dev/null; then
                log_success "Hostname set to $desired_hostname"
            else
                log_debug "Could not set hostname (may already be configured)"
            fi
        fi
    else
        log_info "Tailscale hostname already set: $current_hostname"
    fi
}

# Show Tailscale status
show_tailscale_status() {
    if command_exists tailscale; then
        log_info "Tailscale status:"

        # Get basic status
        local status_output
        if status_output=$(tailscale status 2>/dev/null); then
            echo "$status_output" | head -10 | sed 's/^/  /'

            local line_count
            line_count=$(echo "$status_output" | wc -l)
            if [[ $line_count -gt 10 ]]; then
                echo "  ... and $((line_count - 10)) more devices"
            fi
        else
            echo "  Status not available (may need authentication)"
        fi

        echo

        # Show IP addresses
        local ip_output
        if ip_output=$(tailscale ip -4 2>/dev/null); then
            echo "  Tailscale IPv4: $ip_output"
        fi

        if ip_output=$(tailscale ip -6 2>/dev/null); then
            echo "  Tailscale IPv6: $ip_output"
        fi
    fi

    echo
}

# Verify Tailscale installation
verify_installation() {
    log_info "Verifying Tailscale installation..."

    # Check if tailscale command exists
    if ! command_exists tailscale; then
        log_error "Tailscale command not found"
        return 1
    fi

    # Check if tailscaled service is running
    if ! systemctl is-active tailscaled &>/dev/null; then
        log_error "Tailscale daemon is not running"
        return 1
    fi

    # Check if we can get version
    local version
    if version=$(tailscale version 2>/dev/null); then
        log_success "Tailscale version: $(echo "$version" | head -n1)"
    else
        log_error "Cannot get Tailscale version"
        return 1
    fi

    log_success "Tailscale installation verification passed"
    return 0
}

# Show post-installation notes
show_notes() {
    echo
    log_info "=== Tailscale Installation Complete ==="
    log_info "• Tailscale VPN installed and configured"
    log_info "• Service enabled to start on boot"

    if check_tailscale_auth; then
        log_info "• Device is authenticated and connected"
    else
        log_warn "• Device needs authentication"
        log_info "• Run 'tailscale up' to authenticate"
    fi

    echo
    log_info "Useful commands:"
    log_info "• tailscale status          # Show network status"
    log_info "• tailscale ip              # Show your Tailscale IP"
    log_info "• tailscale ping <device>   # Ping another device"
    log_info "• tailscale up              # Connect/authenticate"
    log_info "• tailscale down            # Disconnect"
    log_info "• tailscale logout          # Sign out"
    echo
    log_info "For auth keys and advanced setup:"
    log_info "• Visit https://login.tailscale.com/admin/settings/keys"
    log_info "• Set TAILSCALE_AUTH_KEY environment variable for automated setup"
    log_info "• Or save auth key to ~/.tailscale-auth-key file"
}

# Main installation function
main() {
    log_info "=== Installing Tailscale ==="

    # Check if we should skip installation
    if ! check_docker_environment; then
        return 0
    fi

    # Check if Tailscale is already installed
    if check_existing_tailscale; then
        # Still try to authenticate if needed
        if ! check_tailscale_auth; then
            log_info "Tailscale is installed but needs authentication"
            authenticate_tailscale || log_warn "Authentication failed - run 'tailscale up' manually"
        fi

        show_tailscale_status
        return 0
    fi

    # Install Tailscale
    add_tailscale_gpg_key || return 1
    add_tailscale_repository || return 1
    install_tailscale || return 1

    # Start service
    start_tailscale_service || return 1

    # Verify installation
    verify_installation || return 1

    # Try to authenticate
    if ! check_tailscale_auth; then
        authenticate_tailscale || log_warn "Authentication failed - run 'tailscale up' manually"
    fi

    # Configure settings
    configure_tailscale

    # Show status
    show_tailscale_status

    # Show completion notes
    show_notes

    log_success "Tailscale installation completed successfully!"
    return 0
}

# Run main function
main "$@"