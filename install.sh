#!/usr/bin/env bash

# Claude-Flake Installation/Uninstallation Script
# Supports macOS, Linux, and WSL with Docker or Nix installation methods

set -euo pipefail

# Script metadata
SCRIPT_VERSION="1.0.0"
GITHUB_REPO="smithclay/claude-flake"
DOCKER_IMAGE="ghcr.io/smithclay/claude-flake:latest"

# Global options
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1" >&2
}

log_step() {
    echo -e "${PURPLE}🔄${NC} $1"
}

log_dry_run() {
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}🔍 [DRY RUN]${NC} $1"
    fi
}

# Execute command with dry-run support
execute_cmd() {
    local cmd="$1"
    local description="${2:-}"
    
    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would execute: $cmd"
        if [[ -n "$description" ]]; then
            log_dry_run "Purpose: $description"
        fi
        return 0
    else
        eval "$cmd"
    fi
}

# Detect operating system
detect_os() {
    local os=""
    case "$(uname -s)" in
        Linux*)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                os="wsl"
            else
                os="linux"
            fi
            ;;
        Darwin*)
            os="macos"
            ;;
        *)
            log_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
    echo "$os"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    local os="$1"
    local missing_deps=()

    log_step "Checking system prerequisites..."

    # Check basic tools
    for cmd in curl git; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install them and run this script again."
        exit 1
    fi

    # Check connectivity
    if ! curl -s --connect-timeout 5 https://github.com >/dev/null; then
        log_error "No internet connectivity detected"
        exit 1
    fi

    log_success "Prerequisites check passed"
}

# Check for existing installation
check_existing_installation() {
    local docker_installed=false
    local nix_installed=false
    local version=""

    # Check for Docker-based installation
    if command_exists docker && docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "claude-flake:latest"; then
        docker_installed=true
    fi

    # Check for Nix-based installation
    if [[ -d "$HOME/.claude" ]] && [[ -f "$HOME/.config/claude-flake/loader.sh" ]]; then
        nix_installed=true
        if command_exists claude; then
            version=$(claude --version 2>/dev/null | head -n1 || echo "unknown")
        fi
    fi

    if [[ "$docker_installed" == true ]] || [[ "$nix_installed" == true ]]; then
        echo "existing"
        if [[ -n "$version" ]]; then
            echo "version:$version"
        fi
        if [[ "$docker_installed" == true ]]; then
            echo "method:docker"
        else
            echo "method:nix"
        fi
    else
        echo "none"
    fi
}

# Backup existing files for Nix installation
backup_existing_files() {
    local backup_dir
    backup_dir="$HOME/.config/claude-flake/backup-$(date +%Y%m%d-%H%M%S)"
    local files_to_backup=(
        "$HOME/.claude"
        "$HOME/.config/claude-flake"
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.npm-global"
    )

    log_step "Creating backup of existing files..."
    
    mkdir -p "$backup_dir"
    local backed_up=false

    for file in "${files_to_backup[@]}"; do
        if [[ -e "$file" ]]; then
            local backup_name
            backup_name=$(basename "$file")
            cp -r "$file" "$backup_dir/$backup_name" 2>/dev/null || true
            backed_up=true
            log_info "Backed up: $file → $backup_dir/$backup_name"
        fi
    done

    if [[ "$backed_up" == true ]]; then
        echo "$backup_dir" > "$backup_dir/backup_manifest.txt"
        echo "backup:$backup_dir"
        log_success "Backup created at: $backup_dir"
    else
        rmdir "$backup_dir" 2>/dev/null || true
        echo "backup:none"
        log_info "No existing files to backup"
    fi
}

# Install Docker method
install_docker() {
    log_step "Installing claude-flake via Docker..."

    # Check if Docker is available
    if ! command_exists docker; then
        log_error "Docker is not installed."
        case "$(detect_os)" in
            macos)
                log_info "Install Docker Desktop from: https://docs.docker.com/desktop/install/mac-install/"
                ;;
            linux|wsl)
                log_info "Install Docker from: https://docs.docker.com/engine/install/"
                ;;
        esac
        exit 1
    fi

    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running. Please start Docker and try again."
        exit 1
    fi

    # Pull the latest image
    log_step "Pulling claude-flake Docker image..."
    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would pull Docker image: $DOCKER_IMAGE"
    else
        if ! docker pull "$DOCKER_IMAGE"; then
            log_error "Failed to pull Docker image"
            exit 1
        fi
    fi

    # Create wrapper script
    local wrapper_dir="$HOME/.local/bin"
    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would create directory: $wrapper_dir"
        log_dry_run "Would create wrapper script: $wrapper_dir/cf-docker"
    else
        mkdir -p "$wrapper_dir"

        cat > "$wrapper_dir/cf-docker" << 'EOF'
#!/usr/bin/env bash

# Claude-Flake Docker wrapper script
# Automatically mounts current directory and Claude credentials

set -euo pipefail

# Default to current directory if no directory specified
WORKSPACE_DIR="${1:-$(pwd)}"

# Validate workspace directory
if [[ ! -d "$WORKSPACE_DIR" ]]; then
    echo "❌ Directory not found: $WORKSPACE_DIR"
    exit 1
fi

# Convert to absolute path
WORKSPACE_DIR=$(cd "$WORKSPACE_DIR" && pwd)

# Validate Claude credentials
CREDENTIALS_FILE="$HOME/.claude/.credentials.json"
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
    echo "❌ Claude credentials not found: $CREDENTIALS_FILE"
    echo "   Please run 'claude auth' to set up credentials first"
    exit 1
fi

echo "🚀 Starting claude-flake container..."
echo "📁 Workspace: $WORKSPACE_DIR"

# Run container with proper mounts
exec docker run -it --rm \
    -v "$WORKSPACE_DIR:/workspace" \
    -v "$CREDENTIALS_FILE:/home/claude/.claude/.credentials.json:ro" \
    -v claude-cache:/home/claude/.cache/nix \
    ghcr.io/smithclay/claude-flake:latest
EOF

        chmod +x "$wrapper_dir/cf-docker"
    fi

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$wrapper_dir:"* ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log_dry_run "Would add $wrapper_dir to PATH in shell configuration"
            case "$(basename "$SHELL")" in
                bash)
                    log_dry_run "Would append to $HOME/.bashrc"
                    ;;
                zsh)
                    log_dry_run "Would append to $HOME/.zshrc"
                    ;;
            esac
        else
            case "$(basename "$SHELL")" in
                bash)
                    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
                    ;;
                zsh)
                    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
                    ;;
            esac
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi

    log_success "Docker installation completed!"
    log_info "Usage:"
    log_info "  cf-docker                    # Use current directory"
    log_info "  cf-docker /path/to/project   # Use specific directory"
    log_info ""
    log_info "Note: You'll need Claude credentials. Run 'claude auth' if you haven't already."
}

# Install Nix method
install_nix() {
    local backup_result
    backup_result=$(backup_existing_files)
    local backup_dir
    backup_dir=$(echo "$backup_result" | grep "^backup:" | cut -d: -f2)

    log_step "Installing claude-flake via Nix..."

    # Check if Nix is installed
    if ! command_exists nix; then
        log_step "Installing Nix package manager..."
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
        
        # Source Nix in current session
        if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
            source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi
    fi

    # Verify Nix installation
    if ! command_exists nix; then
        log_error "Nix installation failed. Please restart your shell and try again."
        exit 1
    fi

    # Enable flakes if not already enabled
    local nix_conf_dir="$HOME/.config/nix"
    local nix_conf="$nix_conf_dir/nix.conf"
    mkdir -p "$nix_conf_dir"
    
    if ! grep -q "experimental-features.*flakes" "$nix_conf" 2>/dev/null; then
        echo "experimental-features = nix-command flakes" >> "$nix_conf"
        log_info "Enabled Nix flakes"
    fi

    # Install claude-flake via home-manager
    log_step "Installing claude-flake home configuration..."
    if [[ "$DRY_RUN" == true ]]; then
        log_dry_run "Would run: nix run --impure --accept-flake-config \"github:$GITHUB_REPO#apps.x86_64-linux.home\""
    elif ! nix run --impure --accept-flake-config "github:$GITHUB_REPO#apps.x86_64-linux.home"; then
        log_error "Failed to install claude-flake"
        
        # Restore backup if available
        if [[ "$backup_dir" != "none" ]] && [[ -d "$backup_dir" ]]; then
            log_step "Restoring backup due to installation failure..."
            restore_backup "$backup_dir"
        fi
        exit 1
    fi

    # Set up shell integration
    local shell_integration_needed=false
    case "$(basename "$SHELL")" in
        bash)
            if ! grep -q "claude-flake/loader.sh" "$HOME/.bashrc" 2>/dev/null; then
                echo 'source ~/.config/claude-flake/loader.sh' >> "$HOME/.bashrc"
                shell_integration_needed=true
            fi
            ;;
        zsh)
            if ! grep -q "claude-flake/loader.sh" "$HOME/.zshrc" 2>/dev/null; then
                echo 'source ~/.config/claude-flake/loader.sh' >> "$HOME/.zshrc"
                shell_integration_needed=true
            fi
            ;;
    esac

    log_success "Nix installation completed!"
    
    if [[ "$backup_dir" != "none" ]]; then
        log_info "Backup created at: $backup_dir"
    fi
    
    if [[ "$shell_integration_needed" == true ]]; then
        log_info "Shell integration added. Please restart your shell or run:"
        log_info "  source ~/.config/claude-flake/loader.sh"
    fi
    
    log_info "Usage:"
    log_info "  claude                       # Start Claude CLI"
    log_info "  cf dev [language]           # Enter development shell"
}

# Restore backup
restore_backup() {
    local backup_dir="$1"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup directory not found: $backup_dir"
        return 1
    fi

    log_step "Restoring backup from: $backup_dir"
    
    # Restore each backed up file/directory
    for item in "$backup_dir"/*; do
        local basename_item
        basename_item=$(basename "$item")
        local target=""
        
        case "$basename_item" in
            .claude)
                target="$HOME/.claude"
                ;;
            .config)
                target="$HOME/.config/claude-flake"
                ;;
            .bashrc)
                target="$HOME/.bashrc"
                ;;
            .zshrc)
                target="$HOME/.zshrc"
                ;;
            .npm-global)
                target="$HOME/.npm-global"
                ;;
            backup_manifest.txt)
                continue
                ;;
        esac
        
        if [[ -n "$target" ]]; then
            if [[ -e "$target" ]]; then
                rm -rf "$target"
            fi
            cp -r "$item" "$target"
            log_info "Restored: $basename_item"
        fi
    done
    
    log_success "Backup restored successfully"
}

# Uninstall Docker method
uninstall_docker() {
    log_step "Uninstalling Docker-based claude-flake..."

    # Remove Docker image
    if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "claude-flake:latest"; then
        docker rmi "$DOCKER_IMAGE" >/dev/null 2>&1 || true
        log_info "Removed Docker image"
    fi

    # Remove volume
    if docker volume ls --format "table {{.Name}}" | grep -q "claude-cache"; then
        docker volume rm claude-cache >/dev/null 2>&1 || true
        log_info "Removed Docker volume"
    fi

    # Remove wrapper script
    if [[ -f "$HOME/.local/bin/cf-docker" ]]; then
        rm "$HOME/.local/bin/cf-docker"
        log_info "Removed wrapper script"
    fi

    log_success "Docker uninstallation completed"
}

# Uninstall Nix method
uninstall_nix() {
    log_step "Uninstalling Nix-based claude-flake..."

    # Find and offer to restore backup
    local backup_dirs=()
    if [[ -d "$HOME/.config/claude-flake" ]]; then
        while IFS= read -r -d '' backup_dir; do
            backup_dirs+=("$backup_dir")
        done < <(find "$HOME/.config/claude-flake" -name "backup-*" -type d -print0 2>/dev/null)
    fi

    local restore_backup=false
    if [[ ${#backup_dirs[@]} -gt 0 ]]; then
        echo "Found backup(s) from previous installation:"
        for i in "${!backup_dirs[@]}"; do
            echo "  $((i+1)). $(basename "${backup_dirs[i]}")"
        done
        echo "  $((${#backup_dirs[@]}+1)). Don't restore backup"
        
        read -r -p "Select backup to restore (1-$((${#backup_dirs[@]}+1))): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#backup_dirs[@]}" ]]; then
            restore_backup=true
            local selected_backup="${backup_dirs[$((choice-1))]}"
        fi
    fi

    # Revert home-manager configuration
    if command_exists home-manager; then
        log_step "Reverting home-manager configuration..."
        home-manager generations | head -n2 | tail -n1 | while read -r gen_info; do
            local gen_path
            gen_path=$(echo "$gen_info" | awk '{print $NF}')
            if [[ -n "$gen_path" ]]; then
                "$gen_path/activate" >/dev/null 2>&1 || true
                log_info "Reverted to previous home-manager generation"
            fi
        done
    fi

    # Remove NPM global packages
    if command_exists npm && [[ -d "$HOME/.npm-global" ]]; then
        npm uninstall -g @anthropic-ai/claude-code >/dev/null 2>&1 || true
        log_info "Removed NPM global packages"
    fi

    # Clean up directories
    for dir in "$HOME/.claude" "$HOME/.config/claude-flake" "$HOME/.npm-global"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            log_info "Removed: $dir"
        fi
    done

    # Remove shell integration
    for shell_rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$shell_rc" ]]; then
            sed -i.bak '/claude-flake\/loader\.sh/d' "$shell_rc" 2>/dev/null || true
            if [[ -f "$shell_rc.bak" ]]; then
                rm "$shell_rc.bak"
            fi
        fi
    done

    # Clean Nix store
    if command_exists nix; then
        nix-collect-garbage >/dev/null 2>&1 || true
        log_info "Cleaned Nix store"
    fi

    # Restore backup if requested
    if [[ "$restore_backup" == true ]] && [[ -n "${selected_backup:-}" ]]; then
        restore_backup "$selected_backup"
    fi

    log_success "Nix uninstallation completed"
}

# Upgrade installation
upgrade_installation() {
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN MODE - Simulating upgrade process"
        echo ""
    fi
    
    local installation_check
    installation_check=$(check_existing_installation)
    
    case "$installation_check" in
        existing*)
            local method
            method=$(echo "$installation_check" | grep "^method:" | cut -d: -f2)
            case "$method" in
                docker)
                    log_step "Upgrading Docker installation..."
                    docker pull "$DOCKER_IMAGE"
                    log_success "Docker image upgraded"
                    ;;
                nix)
                    log_step "Upgrading Nix installation..."
                    nix flake update "github:$GITHUB_REPO" >/dev/null 2>&1 || true
                    nix run --impure --accept-flake-config "github:$GITHUB_REPO#apps.x86_64-linux.home"
                    log_success "Nix installation upgraded"
                    ;;
            esac
            ;;
        none)
            log_error "No existing installation found to upgrade"
            exit 1
            ;;
    esac
}

# Choose installation method
choose_installation_method() {
    local docker_available=false
    local nix_available=false

    # Check Docker availability
    if command_exists docker && docker info >/dev/null 2>&1; then
        docker_available=true
    fi

    # Check Nix availability
    if command_exists nix || curl -s --connect-timeout 5 https://install.determinate.systems/nix >/dev/null; then
        nix_available=true
    fi

    echo ""
    echo "Choose installation method:"
    echo ""
    
    if [[ "$docker_available" == true ]]; then
        echo "  1. 🐳 Docker (Recommended)"
        echo "     ✅ Simple and isolated"
        echo "     ✅ No system modifications"
        echo "     ✅ Easy to remove"
        echo ""
    else
        echo "  1. 🐳 Docker (Not Available)"
        echo "     ❌ Docker not installed or running"
        echo ""
    fi

    if [[ "$nix_available" == true ]]; then
        echo "  2. ❄️  Nix"
        echo "     ✅ Full system integration" 
        echo "     ✅ Powerful development environments"
        echo "     ⚠️  Modifies shell configuration"
        echo ""
    else
        echo "  2. ❄️  Nix (Limited)"
        echo "     ⚠️  Will install Nix package manager"
        echo ""
    fi

    local valid_choices=()
    if [[ "$docker_available" == true ]]; then
        valid_choices+=(1)
    fi
    if [[ "$nix_available" == true ]]; then
        valid_choices+=(2)
    fi

    if [[ ${#valid_choices[@]} -eq 0 ]]; then
        log_error "Neither Docker nor Nix installation methods are available"
        exit 1
    fi

    local choice
    while true; do
        read -r -p "Select installation method (${valid_choices[*]}): " choice
        if [[ " ${valid_choices[*]} " == *" $choice "* ]]; then
            break
        fi
        log_warning "Invalid choice. Please select from: ${valid_choices[*]}"
    done

    case "$choice" in
        1)
            echo "docker"
            ;;
        2)
            echo "nix"
            ;;
    esac
}

# Main installation function
install_claude_flake() {
    local os
    os=$(detect_os)
    
    log_info "🚀 Claude-Flake Installation"
    log_info "Platform: $os"
    echo ""

    check_prerequisites "$os"

    # Check for existing installation
    local installation_check
    installation_check=$(check_existing_installation)
    
    case "$installation_check" in
        existing*)
            local version
            local method
            version=$(echo "$installation_check" | grep "^version:" | cut -d: -f2 || echo "unknown")
            method=$(echo "$installation_check" | grep "^method:" | cut -d: -f2)
            
            log_warning "Claude-flake is already installed ($method method)"
            if [[ "$version" != "unknown" ]]; then
                log_info "Current version: $version"
            fi
            echo ""
            echo "Options:"
            echo "  1. Upgrade existing installation"
            echo "  2. Reinstall (will backup and replace)"
            echo "  3. Cancel"
            
            read -r -p "Choose option (1-3): " choice
            case "$choice" in
                1)
                    upgrade_installation
                    return 0
                    ;;
                2)
                    case "$method" in
                        docker)
                            uninstall_docker
                            install_docker
                            ;;
                        nix)
                            uninstall_nix
                            install_nix
                            ;;
                    esac
                    return 0
                    ;;
                3)
                    log_info "Installation cancelled"
                    return 0
                    ;;
                *)
                    log_error "Invalid choice"
                    exit 1
                    ;;
            esac
            ;;
        none)
            # Fresh installation
            local method
            method=$(choose_installation_method)
            
            case "$method" in
                docker)
                    install_docker
                    ;;
                nix)
                    install_nix
                    ;;
            esac
            ;;
    esac
}

# Main uninstall function
uninstall_claude_flake() {
    log_info "🗑️  Claude-Flake Uninstallation"
    echo ""

    local installation_check
    installation_check=$(check_existing_installation)
    
    case "$installation_check" in
        existing*)
            local method
            method=$(echo "$installation_check" | grep "^method:" | cut -d: -f2)
            
            log_warning "This will completely remove claude-flake from your system"
            read -r -p "Are you sure? (y/N): " confirm
            
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                case "$method" in
                    docker)
                        uninstall_docker
                        ;;
                    nix)
                        uninstall_nix
                        ;;
                esac
                log_success "Claude-flake has been uninstalled"
            else
                log_info "Uninstallation cancelled"
            fi
            ;;
        none)
            log_warning "Claude-flake is not installed"
            ;;
    esac
}

# Show usage information
show_usage() {
    cat << EOF
Claude-Flake Installation Script v$SCRIPT_VERSION

USAGE:
    curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash
    curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash -s -- [OPTIONS]

OPTIONS:
    --install          Install claude-flake (default)
    --uninstall        Remove claude-flake from system
    --upgrade          Upgrade existing installation
    --dry-run          Show what would be done without making changes
    --help             Show this help message

INSTALLATION METHODS:
    Docker            Containerized, isolated installation (recommended)
    Nix               Full system integration with development environments

EXAMPLES:
    # Install (interactive method selection)
    curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash

    # Uninstall
    curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash -s -- --uninstall

    # Upgrade
    curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash -s -- --upgrade

For more information: https://github.com/$GITHUB_REPO
EOF
}

# Parse command-line arguments
parse_args() {
    local action="install"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install)
                action="install"
                shift
                ;;
            --uninstall)
                action="uninstall"
                shift
                ;;
            --upgrade)
                action="upgrade"
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                action="help"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    echo "$action"
}

# Main script logic
main() {
    local action
    action=$(parse_args "$@")
    
    if [[ "$DRY_RUN" == true ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
        echo ""
    fi
    
    case "$action" in
        install)
            install_claude_flake
            ;;
        uninstall)
            uninstall_claude_flake
            ;;
        upgrade)
            upgrade_installation
            ;;
        help)
            show_usage
            ;;
        *)
            log_error "Unknown action: $action"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"