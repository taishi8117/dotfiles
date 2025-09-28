#!/usr/bin/env bash
# lib/installers/system_deps.sh - Install system dependencies

set -euo pipefail

# Source common functions
# shellcheck source=../common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Core system packages
readonly CORE_PACKAGES=(
    # Build essentials
    "build-essential"
    "curl"
    "wget"
    "git"
    "sudo"
    "software-properties-common"
    "ca-certificates"
    "gnupg"
    "lsb-release"
    "apt-transport-https"
)

# Essential command-line tools (as requested)
readonly ESSENTIAL_TOOLS=(
    "jq"            # JSON processor
    "httpie"        # HTTP client
    "ripgrep"       # Fast grep alternative
    "fd-find"       # Fast find alternative
    "fzf"           # Fuzzy finder
    "bat"           # Cat with syntax highlighting
    "tree"          # Directory tree display
    "htop"          # Process viewer
    "xclip"         # Clipboard utility
    "unzip"         # Archive extraction
    "zip"           # Archive creation
)

# Shell environment
readonly SHELL_PACKAGES=(
    "zsh"
    "tmux"
)

# Development packages
readonly DEV_PACKAGES=(
    "python3"
    "python3-pip"
    "python3-venv"
    "cmake"
    "pkg-config"
    "libssl-dev"
)

# Install core packages
install_core_packages() {
    log_info "Installing core system packages..."

    # Update package lists first
    update_package_lists

    local failed_packages=()

    for package in "${CORE_PACKAGES[@]}"; do
        if install_package "$package"; then
            log_debug "✓ $package"
        else
            failed_packages+=("$package")
            log_warn "Failed to install $package"
        fi
    done

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warn "Some core packages failed to install: ${failed_packages[*]}"
        log_warn "This may cause issues with subsequent installations"
    else
        log_success "All core packages installed successfully"
    fi
}

# Install essential tools
install_essential_tools() {
    log_info "Installing essential command-line tools..."

    local failed_packages=()

    for package in "${ESSENTIAL_TOOLS[@]}"; do
        if install_package "$package"; then
            log_debug "✓ $package"
        else
            failed_packages+=("$package")
            log_warn "Failed to install $package"
        fi
    done

    # Special handling for some packages
    handle_special_packages

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warn "Some essential tools failed to install: ${failed_packages[*]}"
    else
        log_success "All essential tools installed successfully"
    fi
}

# Handle packages that need special treatment
handle_special_packages() {
    # fd-find is installed as fdfind on Ubuntu, create symlink
    if command_exists fdfind && ! command_exists fd; then
        local bin_dir="$HOME/.local/bin"
        ensure_dir "$bin_dir"
        if [[ ! -L "$bin_dir/fd" ]]; then
            ln -s "$(which fdfind)" "$bin_dir/fd"
            log_info "Created fd symlink for fdfind"
        fi
    fi

    # Install exa (modern ls replacement) if available
    if ! command_exists exa; then
        if install_package "exa" 2>/dev/null; then
            log_info "Installed exa (modern ls replacement)"
        else
            log_debug "exa not available in repositories (not critical)"
        fi
    fi
}

# Install shell packages
install_shell_packages() {
    log_info "Installing shell environment packages..."

    local failed_packages=()

    for package in "${SHELL_PACKAGES[@]}"; do
        if install_package "$package"; then
            log_debug "✓ $package"
        else
            failed_packages+=("$package")
            log_error "Failed to install $package"
        fi
    done

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_error "Critical shell packages failed: ${failed_packages[*]}"
        return 1
    else
        log_success "Shell packages installed successfully"
    fi
}

# Install development packages
install_dev_packages() {
    log_info "Installing development packages..."

    local failed_packages=()

    for package in "${DEV_PACKAGES[@]}"; do
        if install_package "$package"; then
            log_debug "✓ $package"
        else
            failed_packages+=("$package")
            log_warn "Failed to install $package"
        fi
    done

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warn "Some development packages failed: ${failed_packages[*]}"
    else
        log_success "Development packages installed successfully"
    fi
}

# Install Neovim from PPA (for latest version)
install_neovim() {
    log_info "Installing Neovim..."

    if command_exists nvim; then
        local current_version
        current_version=$(nvim --version | head -n1 | cut -d' ' -f2)
        log_info "Neovim already installed: $current_version"
        return 0
    fi

    # Add Neovim PPA for latest stable version
    if ! grep -q "neovim-ppa/stable" /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Adding Neovim PPA..."
        sudo add-apt-repository -y ppa:neovim-ppa/stable || {
            log_warn "Failed to add Neovim PPA, trying default repository"
            install_package "neovim"
            return 0
        }
        sudo apt-get update
    fi

    # Install Neovim
    if install_package "neovim"; then
        local version
        version=$(nvim --version | head -n1 | cut -d' ' -f2)
        log_success "Neovim installed: $version"
    else
        log_error "Failed to install Neovim"
        return 1
    fi
}

# Setup PATH for local binaries
setup_local_path() {
    local bin_dir="$HOME/.local/bin"
    ensure_dir "$bin_dir"

    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
        log_info "Adding ~/.local/bin to PATH for this session"
        export PATH="$bin_dir:$PATH"
    fi
}

# Verify critical commands are available
verify_installation() {
    log_info "Verifying critical commands..."

    local critical_commands=("git" "curl" "wget" "jq" "httpie" "zsh" "tmux" "nvim")
    local missing_commands=()

    for cmd in "${critical_commands[@]}"; do
        if command_exists "$cmd"; then
            log_debug "✓ $cmd"
        else
            missing_commands+=("$cmd")
        fi
    done

    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Critical commands not found: ${missing_commands[*]}"
        log_error "Please install manually or check package availability"
        return 1
    else
        log_success "All critical commands verified"
        return 0
    fi
}

# Show installed versions
show_versions() {
    log_info "Installed software versions:"

    local commands=(
        "git"
        "curl"
        "jq"
        "http"
        "rg"
        "fd"
        "fzf"
        "bat"
        "zsh"
        "tmux"
        "nvim"
        "python3"
    )

    for cmd in "${commands[@]}"; do
        if command_exists "$cmd"; then
            local version=""
            case "$cmd" in
                "git")
                    version=$(git --version | cut -d' ' -f3)
                    ;;
                "curl")
                    version=$(curl --version | head -n1 | cut -d' ' -f2)
                    ;;
                "jq")
                    version=$(jq --version | sed 's/jq-//')
                    ;;
                "http")
                    version=$(http --version | cut -d' ' -f2)
                    ;;
                "rg")
                    version=$(rg --version | head -n1 | cut -d' ' -f2)
                    ;;
                "fd")
                    version=$(fd --version | cut -d' ' -f2)
                    ;;
                "fzf")
                    version=$(fzf --version | cut -d' ' -f1)
                    ;;
                "bat")
                    version=$(bat --version | cut -d' ' -f2)
                    ;;
                "zsh")
                    version=$(zsh --version | cut -d' ' -f2)
                    ;;
                "tmux")
                    version=$(tmux -V | cut -d' ' -f2)
                    ;;
                "nvim")
                    version=$(nvim --version | head -n1 | cut -d' ' -f2)
                    ;;
                "python3")
                    version=$(python3 --version | cut -d' ' -f2)
                    ;;
            esac
            echo "  $cmd: $version"
        fi
    done
}

# Main installation function
main() {
    log_info "=== Installing System Dependencies ==="

    # Check if we can install packages
    if [[ "$DOTFILES_DOCKER" == "1" ]]; then
        log_info "Docker mode: Installing packages non-interactively"
        export DEBIAN_FRONTEND=noninteractive
    fi

    # Setup environment
    setup_local_path

    # Install packages in order
    install_core_packages || {
        log_error "Core package installation failed"
        return 1
    }

    install_shell_packages || {
        log_error "Shell package installation failed"
        return 1
    }

    install_essential_tools
    install_dev_packages
    install_neovim || {
        log_error "Neovim installation failed"
        return 1
    }

    # Verify everything is working
    verify_installation || {
        log_error "Verification failed"
        return 1
    }

    # Show what we installed
    show_versions

    log_success "System dependencies installation completed!"
    return 0
}

# Run main function
main "$@"