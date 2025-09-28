# Dotfiles Modernization Plan

## Overview
Complete modernization of dotfiles repository to create a robust, idempotent, and error-handled installation system focused on Ubuntu with extensibility for other OSes.

## Key Decisions

### Package Managers
- **Zsh**: Migrate from zplug → **zinit** (faster, actively maintained)
- **Neovim**: Migrate from dein.vim → **lazy.nvim** (modern, Lua-based, faster)
- **Tmux**: Keep **TPM** (already optimal)

### Core Requirements
- Ubuntu-first (22.04, 24.04) with extensible architecture
- Docker container support for safe testing
- Comprehensive error handling and idempotency
- Automatic backups before destructive operations
- Essential tools always installed: httpie, jq, ripgrep, fd-find

### Development Environment
- **Languages**: NVM (Node.js), Rust (rustup), Go (latest), Python3
- **Tools**: Docker (with non-root access), Tailscale
- **Shell**: Zsh with zinit, Tmux with TPM, Neovim with lazy.nvim

## Directory Structure

```
dotfiles/
├── install.sh                    # Main orchestrator
├── CLAUDE.md                     # This plan document
├── Dockerfile.test               # Docker testing environment
├── docker-test.sh               # Automated Docker tests
├── lib/
│   ├── common.sh                # Shared functions, logging, colors
│   ├── backup.sh                # Backup/restore system
│   └── installers/
│       ├── system_deps.sh      # Ubuntu packages
│       ├── zsh.sh              # Zsh + zinit installer
│       ├── nvim.sh             # Neovim + lazy.nvim installer
│       ├── tmux.sh             # Tmux + TPM installer
│       ├── dev_tools.sh        # NVM, Rust, Go installers
│       ├── docker.sh           # Docker + docker-compose
│       └── tailscale.sh        # Tailscale setup
├── tmux/                        # [MOVED from tmux-config submodule]
│   ├── tmux.conf               # Main tmux configuration
│   ├── install.sh              # Idempotent tmux installer
│   └── cleanup.sh              # Safe cleanup with backups
├── zsh/
│   ├── .zshrc                  # Zinit-based configuration
│   ├── .zshenv                 # Environment variables
│   ├── plugins.zsh             # Zinit plugin definitions
│   ├── aliases/                # Existing aliases
│   ├── themes/                 # Existing themes
│   ├── install.sh              # Idempotent zsh installer
│   └── cleanup.sh              # Safe cleanup with backups
└── nvim/                        # [RENAMED from vim/]
    ├── init.lua                # Lazy.nvim bootstrap
    ├── lua/
    │   ├── core/               # Core Neovim settings
    │   │   ├── options.lua     # Neovim options
    │   │   ├── keymaps.lua     # Key mappings
    │   │   └── autocmds.lua    # Autocommands
    │   ├── plugins/            # Plugin specifications
    │   │   ├── init.lua        # Main plugin list
    │   │   ├── lsp.lua         # LSP configuration
    │   │   ├── cmp.lua         # Completion setup
    │   │   └── treesitter.lua  # Syntax highlighting
    │   └── config/             # Plugin configurations
    ├── install.sh              # Idempotent nvim installer
    └── cleanup.sh              # Safe cleanup with backups
```

## Implementation Phases

### Phase 1: Foundation Setup
1. **Move tmux-config submodule to tmux/**
   - Copy all files from tmux-config/tmux/* to tmux/
   - Remove git submodule references
   - Update .gitmodules

2. **Rename vim/ to nvim/**
   - Git move vim/ directory to nvim/
   - Update all references

3. **Create lib/ structure**
   - Create lib/common.sh with shared functions
   - Create lib/backup.sh for backup operations
   - Create lib/installers/ directory

### Phase 2: Core Scripts

#### Main Installer (install.sh)
```bash
#!/usr/bin/env bash
set -euo pipefail

# Features:
- OS detection (Ubuntu versions)
- Docker environment detection
- Component selection (--minimal, --full, --only <component>)
- Dry-run mode (--dry-run)
- Docker mode (--docker)
- Reinstall mode (--reinstall <component>)
- Comprehensive logging to ~/.dotfiles-install.log
- Error handling with line numbers
- Colored output
```

#### Common Functions (lib/common.sh)
```bash
# Shared utilities:
- Logging functions with timestamps
- Color output helpers
- OS detection
- Docker detection
- Error handling setup
- Backup directory management
```

### Phase 3: Component Installers

#### System Dependencies (lib/installers/system_deps.sh)
```bash
# Essential packages (always installed):
build-essential curl wget git sudo
software-properties-common ca-certificates
gnupg lsb-release apt-transport-https

# Shell environment:
zsh tmux

# Neovim (from PPA for latest version):
ppa:neovim-ppa/stable → neovim

# Essential tools (as requested):
jq httpie ripgrep fd-find fzf bat
tree htop xclip unzip zip

# Python:
python3 python3-pip python3-venv

# Development libraries:
cmake pkg-config libssl-dev
```

#### Zsh Installer (lib/installers/zsh.sh)
```bash
# Idempotent operations:
1. Check/install zsh package
2. Install/update zinit to ~/.local/share/zinit
3. Link .zshrc and .zshenv
4. Install zinit plugins
5. Set as default shell (skip in Docker)
```

#### Neovim Installer (lib/installers/nvim.sh)
```bash
# Idempotent operations:
1. Check/install neovim package
2. Backup existing configs if not symlinks
3. Link nvim/ directory to ~/.config/nvim
4. Install pynvim via pip3
5. Bootstrap lazy.nvim (auto-installs on first launch)
```

#### Tmux Installer (lib/installers/tmux.sh)
```bash
# Idempotent operations:
1. Check/install tmux package
2. Backup existing .tmux.conf
3. Install/update TPM
4. Link tmux configs
5. Install TPM plugins
```

#### Development Tools (lib/installers/dev_tools.sh)
```bash
# NVM + Node.js:
- Install NVM to ~/.nvm
- Install latest LTS Node.js
- Install global packages: yarn, pnpm

# Rust:
- Install rustup
- Install stable toolchain
- Install cargo tools: ripgrep, fd-find, bat

# Go:
- Download and install latest Go
- Set up GOPATH
- Install go tools

# Python:
- Ensure pip3, venv, virtualenv
```

#### Docker Installer (lib/installers/docker.sh)
```bash
# Skip if inside Docker container
# Otherwise:
1. Add Docker's official GPG key
2. Add Docker repository
3. Install docker-ce docker-compose-plugin
4. Add user to docker group
5. Enable docker service
```

#### Tailscale Installer (lib/installers/tailscale.sh)
```bash
# Skip if inside Docker container
# Otherwise:
1. Add Tailscale repository
2. Install tailscale
3. Check if already registered
4. Optionally auto-register with auth key
```

### Phase 4: Component Updates

#### Zsh Configuration Migration
- Convert .zshrc from zplug to zinit syntax
- Update plugin loading for better performance
- Add lazy loading where appropriate

#### Neovim Configuration Migration
- Convert from VimScript to Lua
- Migrate from dein.vim to lazy.nvim
- Set up proper plugin lazy loading
- Maintain compatibility with existing keymaps

#### Safe Cleanup Scripts
All cleanup.sh scripts will:
1. Create timestamped backups of important files
2. Preserve history files (.zsh_history, .viminfo)
3. Remove configuration files
4. Log all operations

## Error Handling Strategy

### All Scripts Include:
```bash
set -euo pipefail                    # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'                         # Safe Internal Field Separator
trap 'error_handler $? $LINENO' ERR # Error trap with line numbers
```

### Idempotency Patterns:
```bash
# Check before install
command -v tool || install_tool

# Check symlink targets
[[ "$(readlink link)" == "target" ]] || ln -sfn target link

# Create directories only if missing
[[ -d "$dir" ]] || mkdir -p "$dir"

# Update if exists, install if missing
if [[ -d "$repo" ]]; then
    git -C "$repo" pull
else
    git clone "$url" "$repo"
fi
```

## Docker Testing Strategy

### Dockerfile.test
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y git sudo
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER testuser
WORKDIR /home/testuser
COPY . ./dotfiles
RUN cd dotfiles && ./install.sh --full --docker
```

### Testing Workflow
1. Create/modify scripts (no execution on host)
2. Test in Docker container
3. User provides output/errors
4. Iterate and fix issues
5. Test on fresh VPS once stable

### Docker-Specific Adjustments
- Skip chsh (changing default shell)
- Skip systemd operations
- Non-interactive mode by default
- Skip Tailscale installation
- Use DOTFILES_DOCKER environment variable

## Usage Examples

```bash
# Fresh Ubuntu VPS/Docker setup (everything)
./install.sh --full

# Minimal setup (just zsh, tmux, neovim)
./install.sh --minimal

# Install specific component
./install.sh --only docker

# Reinstall component (backup → clean → install)
./install.sh --reinstall nvim

# Test without making changes
./install.sh --dry-run

# Docker container installation
./install.sh --full --docker
```

## Success Criteria

1. **Reliability**: Scripts work on fresh Ubuntu 22.04/24.04
2. **Idempotency**: Can run multiple times without issues
3. **Safety**: No data loss, automatic backups
4. **Performance**: Fast shell/editor startup with new plugin managers
5. **Maintainability**: Clean code with error handling
6. **Testing**: Works in Docker containers

## Migration Notes

### From Current Setup:
- zplug → zinit (performance improvement)
- dein.vim → lazy.nvim (modern, faster)
- vim/ → nvim/ (Neovim-only focus)
- tmux-config submodule → tmux/ directory
- No error handling → Comprehensive error handling
- No backups → Automatic backup system

### Breaking Changes:
- Vim support dropped (Neovim only)
- Requires Ubuntu 20.04+ (older versions untested)
- New directory structure (vim/ → nvim/)

## Implementation Order

1. Create CLAUDE.md (this file) ✓
2. Move tmux-config to tmux/
3. Create lib/ structure and common functions
4. Create main install.sh
5. Create system_deps.sh installer
6. Update zsh scripts and migrate to zinit
7. Rename vim/ to nvim/ and migrate to lazy.nvim
8. Update tmux scripts
9. Create dev_tools.sh installer
10. Create docker.sh installer
11. Create tailscale.sh installer
12. Create Docker test files
13. Test in Docker containers
14. Fix issues based on testing
15. Document in README.md

## Testing Commands

```bash
# Test in Docker without affecting host
docker run --rm -it -v $(pwd):/dotfiles ubuntu:22.04 bash
cd /dotfiles && ./install.sh --full --docker

# Run automated tests
./docker-test.sh

# Check specific component
./install.sh --dry-run --only nvim
```

---

**Note**: This plan will be implemented step by step with testing in Docker containers to ensure safety and reliability before deployment to production systems.