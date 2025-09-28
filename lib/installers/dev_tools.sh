#!/usr/bin/env bash
# lib/installers/dev_tools.sh - Install development tools (nvm, rust, go, etc.)

set -euo pipefail

# Source common functions
# shellcheck source=../common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Configuration
readonly NVM_DIR="$HOME/.nvm"
readonly CARGO_HOME="$HOME/.cargo"
readonly RUSTUP_HOME="$HOME/.rustup"
readonly GO_VERSION="1.21.3"
readonly GO_INSTALL_DIR="$HOME/.local/go"

# Install NVM and Node.js
install_nvm() {
    log_info "Installing NVM (Node Version Manager)..."

    if [[ -d "$NVM_DIR" ]]; then
        log_info "NVM already installed, updating..."
        # Update NVM
        (
            cd "$NVM_DIR"
            git fetch --tags origin
            git checkout "$(git describe --abbrev=0 --tags --match "v[0-9]*" "$(git rev-list --tags --max-count=1)")"
        ) && log_success "NVM updated" || log_warn "NVM update failed"
    else
        log_info "Installing NVM..."
        # Download and install NVM
        if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash; then
            log_success "NVM installed successfully"
        else
            log_error "Failed to install NVM"
            return 1
        fi
    fi

    # Source NVM for this session
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

    # Verify NVM installation
    if command_exists nvm; then
        local nvm_version
        nvm_version=$(nvm --version)
        log_success "NVM version $nvm_version is available"
    else
        log_error "NVM installation verification failed"
        return 1
    fi
}

# Install Node.js via NVM
install_nodejs() {
    log_info "Installing Node.js via NVM..."

    # Source NVM
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

    if ! command_exists nvm; then
        log_error "NVM not available, cannot install Node.js"
        return 1
    fi

    # Install latest LTS
    log_info "Installing latest LTS Node.js..."
    if nvm install --lts; then
        nvm use --lts
        nvm alias default lts/*
        log_success "Node.js LTS installed and set as default"
    else
        log_error "Failed to install Node.js LTS"
        return 1
    fi

    # Verify Node.js installation
    if command_exists node; then
        local node_version npm_version
        node_version=$(node --version)
        npm_version=$(npm --version)
        log_success "Node.js $node_version and npm $npm_version installed"
    else
        log_error "Node.js installation verification failed"
        return 1
    fi
}

# Install global npm packages
install_npm_packages() {
    log_info "Installing global npm packages..."

    # Source NVM
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

    local packages=(
        "yarn"          # Alternative package manager
        "pnpm"          # Fast package manager
        "typescript"    # TypeScript compiler
        "@types/node"   # Node.js type definitions
        "eslint"        # JavaScript linter
        "prettier"      # Code formatter
        "nodemon"       # Development tool
    )

    local failed_packages=()

    for package in "${packages[@]}"; do
        if npm list -g "$package" &>/dev/null; then
            log_debug "$package already installed globally"
        else
            log_info "Installing $package..."
            if npm install -g "$package" &>/dev/null; then
                log_debug "✓ $package"
            else
                failed_packages+=("$package")
                log_warn "Failed to install $package"
            fi
        fi
    done

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warn "Some npm packages failed to install: ${failed_packages[*]}"
    else
        log_success "All npm packages installed successfully"
    fi
}

# Install Rust via rustup
install_rust() {
    log_info "Installing Rust via rustup..."

    if command_exists rustup; then
        log_info "Rust toolchain already installed, updating..."
        if rustup update; then
            log_success "Rust toolchain updated"
        else
            log_warn "Rust update failed"
        fi
    else
        log_info "Installing Rust toolchain..."
        # Download and install rustup
        if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path; then
            log_success "Rust toolchain installed successfully"
        else
            log_error "Failed to install Rust toolchain"
            return 1
        fi
    fi

    # Source cargo env for this session
    # shellcheck source=/dev/null
    [ -f "$CARGO_HOME/env" ] && source "$CARGO_HOME/env"

    # Verify Rust installation
    if command_exists rustc && command_exists cargo; then
        local rust_version cargo_version
        rust_version=$(rustc --version | cut -d' ' -f2)
        cargo_version=$(cargo --version | cut -d' ' -f2)
        log_success "Rust $rust_version and Cargo $cargo_version installed"
    else
        log_error "Rust installation verification failed"
        return 1
    fi
}

# Install useful Rust tools
install_rust_tools() {
    log_info "Installing useful Rust tools..."

    # Source cargo env
    # shellcheck source=/dev/null
    [ -f "$CARGO_HOME/env" ] && source "$CARGO_HOME/env"

    if ! command_exists cargo; then
        log_error "Cargo not available, cannot install Rust tools"
        return 1
    fi

    local tools=(
        "ripgrep"       # Fast grep alternative (rg)
        "fd-find"       # Fast find alternative (fd)
        "bat"           # Cat with syntax highlighting
        "exa"           # Modern ls alternative
        "tokei"         # Code statistics
        "cargo-edit"    # Cargo subcommands for editing Cargo.toml
        "cargo-watch"   # Watch for changes and run cargo commands
    )

    local failed_tools=()

    for tool in "${tools[@]}"; do
        if cargo install --list | grep -q "^$tool "; then
            log_debug "$tool already installed"
        else
            log_info "Installing $tool..."
            if cargo install "$tool" &>/dev/null; then
                log_debug "✓ $tool"
            else
                failed_tools+=("$tool")
                log_warn "Failed to install $tool"
            fi
        fi
    done

    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        log_warn "Some Rust tools failed to install: ${failed_tools[*]}"
    else
        log_success "All Rust tools installed successfully"
    fi
}

# Install Go
install_go() {
    log_info "Installing Go programming language..."

    # Check if Go is already installed and up to date
    if command_exists go; then
        local current_version
        current_version=$(go version | cut -d' ' -f3 | sed 's/go//')
        if [[ "$current_version" == "$GO_VERSION" ]]; then
            log_info "Go $GO_VERSION already installed"
            return 0
        else
            log_info "Updating Go from $current_version to $GO_VERSION"
        fi
    fi

    # Determine architecture
    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        armv6l) arch="armv6l" ;;
        armv7l) arch="armv7l" ;;
        *)
            log_error "Unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac

    local os
    case "$(uname -s)" in
        Linux) os="linux" ;;
        Darwin) os="darwin" ;;
        *)
            log_error "Unsupported OS: $(uname -s)"
            return 1
            ;;
    esac

    local go_archive="go${GO_VERSION}.${os}-${arch}.tar.gz"
    local download_url="https://go.dev/dl/${go_archive}"
    local temp_dir="/tmp/go_install_$$"

    log_info "Downloading Go $GO_VERSION for $os-$arch..."

    # Create temporary directory
    mkdir -p "$temp_dir"

    # Download Go
    if curl -L -o "$temp_dir/$go_archive" "$download_url"; then
        log_success "Go archive downloaded"
    else
        log_error "Failed to download Go archive"
        rm -rf "$temp_dir"
        return 1
    fi

    # Remove existing Go installation
    if [[ -d "$GO_INSTALL_DIR" ]]; then
        log_info "Removing existing Go installation..."
        rm -rf "$GO_INSTALL_DIR"
    fi

    # Install Go
    log_info "Installing Go to $GO_INSTALL_DIR..."
    ensure_dir "$GO_INSTALL_DIR"
    if tar -C "$GO_INSTALL_DIR" --strip-components=1 -xzf "$temp_dir/$go_archive"; then
        log_success "Go installed successfully"
    else
        log_error "Failed to extract Go archive"
        rm -rf "$temp_dir"
        return 1
    fi

    # Cleanup
    rm -rf "$temp_dir"

    # Add Go to PATH for this session
    export PATH="$GO_INSTALL_DIR/bin:$PATH"

    # Verify Go installation
    if command_exists go; then
        local go_version
        go_version=$(go version | cut -d' ' -f3)
        log_success "Go $go_version installed"
    else
        log_error "Go installation verification failed"
        return 1
    fi
}

# Setup Go environment
setup_go_env() {
    log_info "Setting up Go environment..."

    # Create Go workspace directories
    local go_path="$HOME/go"
    ensure_dir "$go_path/src"
    ensure_dir "$go_path/bin"
    ensure_dir "$go_path/pkg"

    log_success "Go workspace created at $go_path"

    # Install useful Go tools
    if command_exists go; then
        log_info "Installing Go tools..."

        local tools=(
            "golang.org/x/tools/cmd/goimports@latest"
            "golang.org/x/tools/cmd/godoc@latest"
            "github.com/go-delve/delve/cmd/dlv@latest"
            "honnef.co/go/tools/cmd/staticcheck@latest"
        )

        for tool in "${tools[@]}"; do
            if go install "$tool" &>/dev/null; then
                log_debug "✓ $(basename "${tool%@*}")"
            else
                log_warn "Failed to install $tool"
            fi
        done

        log_success "Go tools installed"
    fi
}

# Update shell configuration for new tools
update_shell_config() {
    log_info "Updating shell configuration for development tools..."

    local shell_config=""

    # Determine which shell config to update
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        shell_config="$HOME/.bashrc"
    fi

    if [[ -n "$shell_config" ]]; then
        local config_lines=(
            ""
            "# Development tools configuration (added by dotfiles)"
            "# NVM"
            "export NVM_DIR=\"\$HOME/.nvm\""
            "[ -s \"\$NVM_DIR/nvm.sh\" ] && source \"\$NVM_DIR/nvm.sh\""
            "[ -s \"\$NVM_DIR/bash_completion\" ] && source \"\$NVM_DIR/bash_completion\""
            ""
            "# Rust"
            "[ -f \"\$HOME/.cargo/env\" ] && source \"\$HOME/.cargo/env\""
            ""
            "# Go"
            "export GOROOT=\"$GO_INSTALL_DIR\""
            "export GOPATH=\"\$HOME/go\""
            "export PATH=\"\$GOROOT/bin:\$GOPATH/bin:\$PATH\""
        )

        # Check if our configuration is already present
        if ! grep -q "# Development tools configuration (added by dotfiles)" "$shell_config" 2>/dev/null; then
            log_info "Adding development tools configuration to $shell_config"
            for line in "${config_lines[@]}"; do
                echo "$line" >> "$shell_config"
            done
            log_success "Shell configuration updated"
        else
            log_info "Development tools configuration already present in shell config"
        fi
    else
        log_warn "No shell configuration file found to update"
    fi
}

# Verify all installations
verify_installations() {
    log_info "Verifying development tools installations..."

    local tools=(
        "nvm:Node Version Manager"
        "node:Node.js"
        "npm:NPM"
        "rustc:Rust compiler"
        "cargo:Cargo"
        "go:Go language"
    )

    local missing_tools=()

    for tool_info in "${tools[@]}"; do
        local tool="${tool_info%:*}"
        local name="${tool_info#*:}"

        if [[ "$tool" == "nvm" ]]; then
            # Special check for NVM
            if [[ -s "$NVM_DIR/nvm.sh" ]]; then
                log_debug "✓ $name"
            else
                missing_tools+=("$name")
            fi
        else
            if command_exists "$tool"; then
                log_debug "✓ $name"
            else
                missing_tools+=("$name")
            fi
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warn "Some development tools are not available: ${missing_tools[*]}"
        log_warn "You may need to restart your shell or source your configuration"
        return 1
    else
        log_success "All development tools verified"
        return 0
    fi
}

# Show installed versions
show_versions() {
    log_info "Installed development tools versions:"

    # NVM
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        # shellcheck source=/dev/null
        source "$NVM_DIR/nvm.sh"
        echo "  nvm: $(nvm --version)"
    fi

    # Node.js and npm
    if command_exists node; then
        echo "  node: $(node --version)"
        echo "  npm: $(npm --version)"
    fi

    # Yarn and pnpm
    command_exists yarn && echo "  yarn: $(yarn --version)"
    command_exists pnpm && echo "  pnpm: $(pnpm --version)"

    # Rust
    if command_exists rustc; then
        echo "  rust: $(rustc --version | cut -d' ' -f2)"
        echo "  cargo: $(cargo --version | cut -d' ' -f2)"
    fi

    # Go
    if command_exists go; then
        echo "  go: $(go version | cut -d' ' -f3 | sed 's/go//')"
    fi

    echo
}

# Show post-installation notes
show_notes() {
    echo
    log_info "=== Development Tools Installation Complete ==="
    log_info "Installed tools:"
    log_info "• NVM (Node Version Manager) with latest LTS Node.js"
    log_info "• Global npm packages: yarn, pnpm, typescript, eslint, prettier"
    log_info "• Rust toolchain with cargo"
    log_info "• Useful Rust tools: ripgrep, fd-find, bat, exa, tokei"
    log_info "• Go programming language with common tools"
    echo
    log_info "Next steps:"
    log_info "• Restart your shell or run: source ~/.zshrc"
    log_info "• Use 'nvm list' to see installed Node.js versions"
    log_info "• Use 'nvm use <version>' to switch Node.js versions"
    log_info "• Use 'cargo --version' to verify Rust installation"
    log_info "• Use 'go version' to verify Go installation"
    echo
    log_info "Useful commands:"
    log_info "• rg: ripgrep (fast grep)"
    log_info "• fd: find alternative"
    log_info "• bat: cat with syntax highlighting"
    log_info "• exa: modern ls alternative"
}

# Main installation function
main() {
    log_info "=== Installing Development Tools ==="

    # Install NVM and Node.js
    install_nvm || return 1
    install_nodejs || return 1
    install_npm_packages

    # Install Rust
    install_rust || return 1
    install_rust_tools

    # Install Go
    install_go || return 1
    setup_go_env

    # Update shell configuration
    update_shell_config

    # Show versions
    show_versions

    # Verify installations
    verify_installations

    # Show completion notes
    show_notes

    log_success "Development tools installation completed successfully!"
    return 0
}

# Run main function
main "$@"