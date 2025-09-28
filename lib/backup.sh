#!/usr/bin/env bash
# lib/backup.sh - Backup and restore functionality

# Source common functions
# shellcheck source=./common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Backup important dotfiles before cleanup
backup_dotfiles() {
    local component="${1:-all}"

    log_info "Creating backup for component: $component"

    case "$component" in
        "zsh"|"all")
            backup_zsh_files
            ;;
        "nvim"|"vim"|"all")
            backup_nvim_files
            ;;
        "tmux"|"all")
            backup_tmux_files
            ;;
        *)
            log_warn "Unknown component for backup: $component"
            ;;
    esac
}

# Backup zsh files
backup_zsh_files() {
    log_info "Backing up zsh configuration..."

    # Backup history (most important)
    backup_item "$HOME/.zsh_history" "zsh_history"

    # Backup other zsh files
    backup_item "$HOME/.zshrc" "zshrc"
    backup_item "$HOME/.zshenv" "zshenv"
    backup_item "$HOME/.zsh_sessions" "zsh_sessions"
    backup_item "$HOME/.zplug" "zplug"

    log_success "Zsh backup completed"
}

# Backup neovim files
backup_nvim_files() {
    log_info "Backing up neovim configuration..."

    # Backup important data directories
    backup_item "$HOME/.local/share/nvim/shada" "nvim_shada"
    backup_item "$HOME/.local/state/nvim" "nvim_state"
    backup_item "$HOME/.cache/nvim" "nvim_cache"

    # Backup existing configs if they're not symlinks
    if [[ -e "$HOME/.config/nvim" ]] && [[ ! -L "$HOME/.config/nvim" ]]; then
        backup_item "$HOME/.config/nvim" "nvim_config"
    fi

    if [[ -e "$HOME/.vim" ]] && [[ ! -L "$HOME/.vim" ]]; then
        backup_item "$HOME/.vim" "vim_config"
    fi

    # Backup viminfo if it exists
    backup_item "$HOME/.viminfo" "viminfo"

    log_success "Neovim backup completed"
}

# Backup tmux files
backup_tmux_files() {
    log_info "Backing up tmux configuration..."

    # Backup tmux resurrect sessions (very important)
    backup_item "$HOME/.tmux/resurrect" "tmux_resurrect"

    # Backup main config if not a symlink
    if [[ -e "$HOME/.tmux.conf" ]] && [[ ! -L "$HOME/.tmux.conf" ]]; then
        backup_item "$HOME/.tmux.conf" "tmux.conf"
    fi

    # Backup tmux directory if not managed by us
    if [[ -e "$HOME/.tmux" ]] && [[ ! -L "$HOME/.tmux" ]]; then
        backup_item "$HOME/.tmux" "tmux_dir"
    fi

    log_success "Tmux backup completed"
}

# Restore from backup
restore_from_backup() {
    local backup_date="$1"

    if [[ -z "$backup_date" ]]; then
        log_error "Please specify backup date (YYYYMMDD_HHMMSS)"
        list_backups
        return 1
    fi

    local backup_path="$HOME/.dotfiles-backup/$backup_date"

    if [[ ! -d "$backup_path" ]]; then
        log_error "Backup not found: $backup_path"
        list_backups
        return 1
    fi

    log_info "Restoring from backup: $backup_path"

    # Restore each backed up item
    for item in "$backup_path"/*; do
        if [[ -e "$item" ]]; then
            local basename_item="$(basename "$item")"
            local original_name="${basename_item%.*}"  # Remove timestamp
            local restore_path=""

            case "$original_name" in
                "zsh_history")
                    restore_path="$HOME/.zsh_history"
                    ;;
                "zshrc")
                    restore_path="$HOME/.zshrc"
                    ;;
                "zshenv")
                    restore_path="$HOME/.zshenv"
                    ;;
                "nvim_config")
                    restore_path="$HOME/.config/nvim"
                    ;;
                "vim_config")
                    restore_path="$HOME/.vim"
                    ;;
                "viminfo")
                    restore_path="$HOME/.viminfo"
                    ;;
                "tmux.conf")
                    restore_path="$HOME/.tmux.conf"
                    ;;
                "tmux_resurrect")
                    restore_path="$HOME/.tmux/resurrect"
                    ;;
                *)
                    log_warn "Unknown backup item: $basename_item"
                    continue
                    ;;
            esac

            if [[ -n "$restore_path" ]]; then
                # Remove current item if it exists
                if [[ -e "$restore_path" ]] || [[ -L "$restore_path" ]]; then
                    rm -rf "$restore_path"
                fi

                # Restore from backup
                ensure_dir "$(dirname "$restore_path")"
                cp -r "$item" "$restore_path"
                log_success "Restored $original_name to $restore_path"
            fi
        fi
    done

    log_success "Restore completed from $backup_path"
}

# List available backups
list_backups() {
    local backup_root="$HOME/.dotfiles-backup"

    if [[ ! -d "$backup_root" ]]; then
        log_info "No backups found (no backup directory)"
        return 0
    fi

    log_info "Available backups:"
    local found=0

    for backup_dir in "$backup_root"/*; do
        if [[ -d "$backup_dir" ]]; then
            local backup_name="$(basename "$backup_dir")"
            local size="$(du -sh "$backup_dir" 2>/dev/null | cut -f1)"
            local count="$(find "$backup_dir" -type f | wc -l)"
            echo "  $backup_name ($size, $count files)"
            found=1
        fi
    done

    if [[ $found -eq 0 ]]; then
        log_info "No backups found"
    fi
}

# Clean old backups (keep last N)
clean_old_backups() {
    local keep_count="${1:-10}"
    local backup_root="$HOME/.dotfiles-backup"

    if [[ ! -d "$backup_root" ]]; then
        return 0
    fi

    log_info "Cleaning old backups (keeping last $keep_count)..."

    # Get sorted list of backup directories (newest first)
    local backup_dirs=()
    while IFS= read -r -d '' dir; do
        backup_dirs+=("$dir")
    done < <(find "$backup_root" -maxdepth 1 -type d -name "????????_??????" -print0 | sort -z -r)

    # Remove old backups
    local removed=0
    for ((i = keep_count; i < ${#backup_dirs[@]}; i++)); do
        local backup_dir="${backup_dirs[i]}"
        log_info "Removing old backup: $(basename "$backup_dir")"
        rm -rf "$backup_dir"
        ((removed++))
    done

    if [[ $removed -gt 0 ]]; then
        log_success "Removed $removed old backup(s)"
    else
        log_info "No old backups to remove"
    fi
}

# Create a manual backup with custom name
create_manual_backup() {
    local backup_name="${1:-manual_$(date +%Y%m%d_%H%M%S)}"
    local backup_path="$HOME/.dotfiles-backup/$backup_name"

    log_info "Creating manual backup: $backup_name"

    # Override global backup directory for this operation
    local original_backup_dir="$BACKUP_DIR"
    BACKUP_DIR="$backup_path"

    # Create the backup
    backup_dotfiles "all"

    # Restore original backup directory
    BACKUP_DIR="$original_backup_dir"

    log_success "Manual backup created: $backup_path"
}

# Export functions
export -f backup_dotfiles backup_zsh_files backup_nvim_files backup_tmux_files
export -f restore_from_backup list_backups clean_old_backups create_manual_backup