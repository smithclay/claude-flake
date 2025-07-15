#!/usr/bin/env bash
# smart-lint.sh - Minimal MegaLinter + Nix wrapper for Claude Code
#
# SYNOPSIS
#   smart-lint.sh [options]
#
# DESCRIPTION
#   Runs MegaLinter for comprehensive multi-language linting and 
#   Nix-specific tools for .nix files. Maintains same exit codes.
#
# OPTIONS
#   --debug       Enable debug output
#   --fast        Skip slow checks (placeholder for compatibility)
#
# EXIT CODES
#   0 - Success (all checks passed)
#   1 - General error (missing dependencies, etc.)
#   2 - ANY issues found OR success (always exit 2 for Claude continuity)

# Don't use set -e - we need to control exit codes carefully
set +e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Debug mode
DEBUG_MODE=0

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_debug() {
    [[ "$DEBUG_MODE" == "1" ]] && echo -e "${BLUE}[DEBUG]${NC} $*" >&2
}

# Error tracking
ERROR_COUNT=0
ERRORS=()

add_error() {
    ERROR_COUNT=$((ERROR_COUNT + 1))
    ERRORS+=("$1")
}

print_summary() {
    if [[ $ERROR_COUNT -gt 0 ]]; then
        echo -e "\n${BLUE}═══ Summary ═══${NC}" >&2
        for error in "${ERRORS[@]}"; do
            echo -e "${RED}❌${NC} $error" >&2
        done
        
        echo -e "\n${RED}Found $ERROR_COUNT issue(s) that MUST be fixed!${NC}" >&2
        echo -e "${RED}════════════════════════════════════════════${NC}" >&2
        echo -e "${RED}❌ ALL ISSUES ARE BLOCKING ❌${NC}" >&2
        echo -e "${RED}════════════════════════════════════════════${NC}" >&2
        echo -e "${RED}Fix EVERYTHING above until all checks are ✅ GREEN${NC}" >&2
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if MegaLinter dependencies are available
megalinter_available() {
    command_exists npx && command_exists node && command_exists docker
}

# Run MegaLinter
run_megalinter() {
    if ! megalinter_available; then
        log_error "MegaLinter requirements not met - need npx, node, and docker"
        add_error "MegaLinter dependencies missing (install node, npx, docker)"
        return 1
    fi
    
    log_info "Running MegaLinter..."
    
    local megalinter_env=""
    if [[ "$DEBUG_MODE" == "1" ]]; then
        megalinter_env="LOG_LEVEL=DEBUG"
    fi
    
    # Run MegaLinter and capture exit code
    local megalinter_output
    if ! megalinter_output=$(env "$megalinter_env" npx mega-linter-runner --path . 2>&1); then
        local exit_code=$?
        log_debug "MegaLinter exit code: $exit_code"
        
        # Parse output for specific errors if possible
        if echo "$megalinter_output" | grep -q "ERROR\|❌"; then
            add_error "MegaLinter found formatting or linting issues"
            # Show relevant error lines in debug mode
            if [[ "$DEBUG_MODE" == "1" ]]; then
                echo "$megalinter_output" | grep -E "(ERROR|❌)" | head -5 >&2
            fi
        else
            add_error "MegaLinter execution failed"
        fi
        
        return $exit_code
    fi
    
    log_debug "MegaLinter completed successfully"
    return 0
}

# Run Nix-specific linting (not supported by MegaLinter)
run_nix_linting() {
    # Only run if we have .nix files
    if ! find . -maxdepth 1 -name "*.nix" -type f | grep -q .; then
        log_debug "No .nix files found, skipping Nix linting"
        return 0
    fi
    
    log_info "Running Nix linters..."
    
    # Check if we're in a nix shell or need to enter one
    local in_nix_shell="${IN_NIX_SHELL:-0}"
    
    if [[ "$in_nix_shell" != "0" ]] || command_exists nixfmt; then
        # Run directly
        run_nix_tools_direct
    elif [[ -f "flake.nix" ]]; then
        # Try to run in nix shell
        log_info "Entering nix develop shell for Nix tools..."
        if ! nix develop .#nix --command bash -c "$(declare -f run_nix_tools_direct); run_nix_tools_direct"; then
            add_error "Nix linting failed in nix develop shell"
        fi
    else
        log_debug "No nix tools available and no flake.nix found"
        add_error "Nix files found but no formatter available (install nixfmt or run in nix shell)"
    fi
}

# Run nix tools directly (called both locally and in nix shell)
run_nix_tools_direct() {
    local nix_files
    nix_files=$(find . -name "*.nix" -type f | grep -v -E "(result/|/nix/store/)" | head -20)
    
    if [[ -z "$nix_files" ]]; then
        return 0
    fi
    
    # Format with nixfmt (primary), nixpkgs-fmt, or alejandra
    local formatter_found=false
    
    if command_exists nixfmt; then
        formatter_found=true
        if ! echo "$nix_files" | tr '\n' '\0' | xargs -0 nixfmt --check 2>/dev/null; then
            if ! echo "$nix_files" | tr '\n' '\0' | xargs -0 nixfmt 2>/dev/null; then
                add_error "nixfmt formatting failed"
            fi
        fi
    elif command_exists nixpkgs-fmt; then
        formatter_found=true
        if ! echo "$nix_files" | xargs nixpkgs-fmt --check 2>/dev/null; then
            if ! echo "$nix_files" | xargs nixpkgs-fmt 2>/dev/null; then
                add_error "nixpkgs-fmt formatting failed"
            fi
        fi
    elif command_exists alejandra; then
        formatter_found=true
        if ! echo "$nix_files" | xargs alejandra --check 2>/dev/null; then
            if ! echo "$nix_files" | xargs alejandra 2>/dev/null; then
                add_error "alejandra formatting failed"
            fi
        fi
    fi
    
    if [[ "$formatter_found" == "false" ]]; then
        add_error "No Nix formatter available (nixfmt, nixpkgs-fmt, or alejandra)"
    fi
    
    # Static analysis with statix
    if command_exists statix; then
        if ! statix check . 2>/dev/null; then
            add_error "statix found anti-patterns in Nix code"
        fi
    fi
    
    # Shell script linting
    local shell_files
    shell_files=$(find . -name "*.sh" -type f | grep -v -E "(result/|/nix/store/)" | head -10)
    
    if [[ -n "$shell_files" ]] && command_exists shellcheck; then
        if ! echo "$shell_files" | xargs shellcheck 2>/dev/null; then
            add_error "shellcheck found issues in shell scripts"
        fi
    fi
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            DEBUG_MODE=1
            shift
            ;;
        --fast)
            # Placeholder for compatibility - currently unused
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 2
            ;;
    esac
done

# Print header
echo "" >&2
echo "🔍 Style Check - Validating code formatting..." >&2
echo "────────────────────────────────────────────" >&2

# Main execution
main() {
    # Run MegaLinter for supported languages
    run_megalinter
    
    # Run Nix-specific tools separately
    run_nix_linting
    
    # Print summary
    print_summary
    
    # Return appropriate exit code
    if [[ $ERROR_COUNT -gt 0 ]]; then
        return 2
    else
        return 0
    fi
}

# Execute main function
main
exit_code=$?

# Final message and exit (always exit 2 for Claude continuity)
if [[ $exit_code -eq 2 ]]; then
    echo -e "\n${RED}🛑 FAILED - Fix all issues above! 🛑${NC}" >&2
    echo -e "${YELLOW}📋 NEXT STEPS:${NC}" >&2
    echo -e "${YELLOW}  1. Fix the issues listed above${NC}" >&2
    echo -e "${YELLOW}  2. Verify the fix by running the lint command again${NC}" >&2
    echo -e "${YELLOW}  3. Continue with your original task${NC}" >&2
    exit 2
else
    # Always exit with 2 so Claude sees the continuation message
    echo -e "\n${YELLOW}👉 Style clean. Continue with your task.${NC}" >&2
    exit 2
fi