#!/usr/bin/env bash
# lib/installers/docker.sh - Install Docker and Docker Compose

set -euo pipefail

# Source common functions
# shellcheck source=../common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Configuration
readonly DOCKER_GPG_KEY_URL="https://download.docker.com/linux/ubuntu/gpg"
readonly DOCKER_REPO_URL="https://download.docker.com/linux/ubuntu"

# Check if we're running inside Docker
check_docker_environment() {
    if [[ "$DOTFILES_DOCKER" == "1" ]]; then
        log_info "Running inside Docker container - skipping Docker installation"
        return 1
    fi
    return 0
}

# Check if Docker is already installed
check_existing_docker() {
    if command_exists docker; then
        local docker_version
        docker_version=$(docker --version | cut -d' ' -f3 | sed 's/,//')
        log_info "Docker is already installed: $docker_version"

        # Check if user is in docker group
        if groups "$USER" | grep -q docker; then
            log_info "User $USER is already in docker group"
        else
            log_warn "User $USER is not in docker group"
            return 1
        fi

        # Check if Docker daemon is running
        if docker info &>/dev/null; then
            log_info "Docker daemon is running"
        else
            log_warn "Docker daemon is not running"
        fi

        return 0
    fi
    return 1
}

# Remove old Docker installations
remove_old_docker() {
    log_info "Removing old Docker installations..."

    local old_packages=(
        "docker.io"
        "docker-doc"
        "docker-compose"
        "docker-compose-v2"
        "podman-docker"
        "containerd"
        "runc"
    )

    local packages_to_remove=()
    for package in "${old_packages[@]}"; do
        if package_installed "$package"; then
            packages_to_remove+=("$package")
        fi
    done

    if [[ ${#packages_to_remove[@]} -gt 0 ]]; then
        log_info "Removing old packages: ${packages_to_remove[*]}"
        sudo apt-get remove -y "${packages_to_remove[@]}" || log_warn "Failed to remove some old packages"
    else
        log_info "No old Docker packages found"
    fi
}

# Add Docker's official GPG key
add_docker_gpg_key() {
    log_info "Adding Docker's official GPG key..."

    # Create keyring directory
    ensure_dir "/etc/apt/keyrings"

    # Download and add GPG key
    if curl -fsSL "$DOCKER_GPG_KEY_URL" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        log_success "Docker GPG key added"
    else
        log_error "Failed to add Docker GPG key"
        return 1
    fi
}

# Add Docker repository
add_docker_repository() {
    log_info "Adding Docker repository..."

    # Get OS information
    local os_codename
    os_codename=$(lsb_release -cs)

    # Add repository
    local repo_line="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $DOCKER_REPO_URL $os_codename stable"

    if echo "$repo_line" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; then
        log_success "Docker repository added"
    else
        log_error "Failed to add Docker repository"
        return 1
    fi

    # Update package lists
    update_package_lists
}

# Install Docker Engine
install_docker_engine() {
    log_info "Installing Docker Engine..."

    local docker_packages=(
        "docker-ce"
        "docker-ce-cli"
        "containerd.io"
        "docker-buildx-plugin"
        "docker-compose-plugin"
    )

    local failed_packages=()

    for package in "${docker_packages[@]}"; do
        if install_package "$package"; then
            log_debug "✓ $package"
        else
            failed_packages+=("$package")
            log_error "Failed to install $package"
        fi
    done

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_error "Docker installation failed: ${failed_packages[*]}"
        return 1
    else
        log_success "Docker Engine installed successfully"
    fi
}

# Add user to docker group
add_user_to_docker_group() {
    log_info "Adding user to docker group..."

    # Create docker group if it doesn't exist
    if ! getent group docker &>/dev/null; then
        sudo groupadd docker
        log_info "Created docker group"
    fi

    # Add current user to docker group
    if sudo usermod -aG docker "$USER"; then
        log_success "User $USER added to docker group"
        log_warn "You need to log out and log back in for this to take effect"
        log_warn "Or run: newgrp docker"
    else
        log_error "Failed to add user to docker group"
        return 1
    fi
}

# Start and enable Docker service
start_docker_service() {
    log_info "Starting Docker service..."

    # Start Docker service
    if sudo systemctl start docker; then
        log_success "Docker service started"
    else
        log_error "Failed to start Docker service"
        return 1
    fi

    # Enable Docker service to start on boot
    if sudo systemctl enable docker; then
        log_success "Docker service enabled for startup"
    else
        log_warn "Failed to enable Docker service for startup"
    fi

    # Enable containerd service
    if sudo systemctl enable containerd; then
        log_success "Containerd service enabled"
    else
        log_warn "Failed to enable containerd service"
    fi
}

# Test Docker installation
test_docker() {
    log_info "Testing Docker installation..."

    # Test Docker without sudo (may fail if user needs to re-login)
    if docker run --rm hello-world &>/dev/null; then
        log_success "Docker test passed (no sudo required)"
        return 0
    fi

    # Test Docker with sudo
    if sudo docker run --rm hello-world &>/dev/null; then
        log_success "Docker test passed (sudo required)"
        log_warn "Docker works with sudo. Log out and back in to use without sudo."
        return 0
    else
        log_error "Docker test failed"
        return 1
    fi
}

# Install Docker Compose (standalone)
install_docker_compose_standalone() {
    log_info "Installing Docker Compose standalone..."

    # Docker Compose plugin should be installed with Docker Engine
    # But let's also install the standalone version for compatibility

    local compose_version="v2.23.0"
    local compose_url="https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-$(uname -s)-$(uname -m)"
    local compose_path="/usr/local/bin/docker-compose"

    # Download Docker Compose
    if sudo curl -L "$compose_url" -o "$compose_path"; then
        sudo chmod +x "$compose_path"
        log_success "Docker Compose standalone installed"
    else
        log_warn "Failed to install Docker Compose standalone (plugin version should still work)"
    fi
}

# Verify Docker installation
verify_installation() {
    log_info "Verifying Docker installation..."

    # Check Docker
    if ! command_exists docker; then
        log_error "Docker command not found"
        return 1
    fi

    # Check Docker Compose plugin
    if docker compose version &>/dev/null; then
        log_success "Docker Compose plugin available"
    else
        log_warn "Docker Compose plugin not available"
    fi

    # Check Docker Compose standalone
    if command_exists docker-compose; then
        log_success "Docker Compose standalone available"
    else
        log_debug "Docker Compose standalone not available (not critical)"
    fi

    # Check if Docker daemon is accessible
    if docker info &>/dev/null; then
        log_success "Docker daemon is accessible"
    elif sudo docker info &>/dev/null; then
        log_warn "Docker daemon accessible with sudo only"
        log_warn "User may need to log out and back in"
    else
        log_error "Cannot access Docker daemon"
        return 1
    fi

    log_success "Docker installation verification passed"
    return 0
}

# Show Docker information
show_docker_info() {
    log_info "Docker installation information:"

    # Docker version
    if command_exists docker; then
        echo "  Docker: $(docker --version | cut -d' ' -f3 | sed 's/,//')"
    fi

    # Docker Compose versions
    if docker compose version &>/dev/null; then
        echo "  Docker Compose (plugin): $(docker compose version --short)"
    fi

    if command_exists docker-compose; then
        echo "  Docker Compose (standalone): $(docker-compose --version | cut -d' ' -f4 | sed 's/,//')"
    fi

    # Docker daemon status
    if systemctl is-active docker &>/dev/null; then
        echo "  Docker service: active"
    else
        echo "  Docker service: inactive"
    fi

    echo
}

# Show post-installation notes
show_notes() {
    echo
    log_info "=== Docker Installation Complete ==="
    log_info "• Docker Engine with latest features"
    log_info "• Docker Compose plugin"
    log_info "• User added to docker group"
    log_info "• Service configured to start on boot"
    echo
    log_info "Important notes:"
    log_info "• Log out and log back in to use Docker without sudo"
    log_info "• Or run 'newgrp docker' to activate group membership"
    log_info "• Use 'docker compose' (new) instead of 'docker-compose' (old)"
    echo
    log_info "Useful commands:"
    log_info "• docker run hello-world    # Test installation"
    log_info "• docker ps                 # List running containers"
    log_info "• docker images             # List images"
    log_info "• docker compose up         # Start services from compose file"
    log_info "• docker system prune       # Clean up unused resources"
}

# Main installation function
main() {
    log_info "=== Installing Docker ==="

    # Check if we should skip installation
    if ! check_docker_environment; then
        return 0
    fi

    # Check if Docker is already properly installed
    if check_existing_docker; then
        log_info "Docker is already properly installed"
        show_docker_info
        return 0
    fi

    # Pre-installation setup
    remove_old_docker
    add_docker_gpg_key || return 1
    add_docker_repository || return 1

    # Install Docker
    install_docker_engine || return 1

    # Post-installation setup
    add_user_to_docker_group || return 1
    start_docker_service || return 1

    # Install Docker Compose standalone for compatibility
    install_docker_compose_standalone

    # Test installation
    test_docker || return 1

    # Verify installation
    verify_installation || return 1

    # Show information
    show_docker_info

    # Show completion notes
    show_notes

    log_success "Docker installation completed successfully!"
    return 0
}

# Run main function
main "$@"