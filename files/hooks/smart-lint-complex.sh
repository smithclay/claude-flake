#!/usr/bin/env bash
# smart-lint.sh - Intelligent project-aware code quality checks for Claude Code
#
# SYNOPSIS
#   smart-lint.sh [options]
#
# DESCRIPTION
#   Automatically detects project type and runs ALL quality checks.
#   Every issue found is blocking - code must be 100% clean to proceed.
#
# OPTIONS
#   --debug       Enable debug output
#   --fast        Skip slow checks (import cycles, security scans)
#
# EXIT CODES
#   0 - Success (all checks passed - everything is ✅ GREEN)
#   1 - General error (missing dependencies, etc.)
#   2 - ANY issues found - ALL must be fixed
#
# CONFIGURATION
#   Project-specific overrides can be placed in .claude-hooks-config.sh
#   See inline documentation for all available options.

# Don't use set -e - we need to control exit codes carefully
set +e

# ============================================================================
# COLOR DEFINITIONS AND UTILITIES
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Debug mode
CLAUDE_HOOKS_DEBUG="${CLAUDE_HOOKS_DEBUG:-0}"

# Logging functions
log_debug() {
    [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]] && echo -e "${CYAN}[DEBUG]${NC} $*" >&2
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# shellcheck disable=SC2317 # Used by external scripts that source this file
log_success() {
    echo -e "${GREEN}[OK]${NC} $*" >&2
}

# Performance timing
time_start() {
    if [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]]; then
        echo $(($(date +%s%N)/1000000))
    fi
}

time_end() {
    if [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]]; then
        local start=$1
        local end=$(($(date +%s%N)/1000000))
        local duration=$((end - start))
        log_debug "Execution time: ${duration}ms"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if MegaLinter is available
megalinter_available() {
    command_exists npx && command_exists node && command_exists docker
}

# Run MegaLinter and parse results
run_megalinter() {
    local project_types="$1"
    
    if ! megalinter_available; then
        log_error "MegaLinter requirements not met - need npx, node, and docker"
        add_error "MegaLinter dependencies missing"
        return 1
    fi
    
    log_info "Running MegaLinter for languages: $project_types"
    
    # Set up MegaLinter environment variables
    local megalinter_env=""
    
    # Enable only the languages we detected
    case "$project_types" in
        *go*) megalinter_env+="ENABLE_GO=true " ;;
    esac
    case "$project_types" in
        *python*) megalinter_env+="ENABLE_PYTHON=true " ;;
    esac
    case "$project_types" in
        *javascript*) megalinter_env+="ENABLE_JAVASCRIPT=true " ;;
    esac
    case "$project_types" in
        *rust*) megalinter_env+="ENABLE_RUST=true " ;;
    esac
    
    # Run MegaLinter with our configuration
    local megalinter_output
    local megalinter_exit_code
    
    if [[ "$CLAUDE_HOOKS_DEBUG" == "1" ]]; then
        megalinter_env+="LOG_LEVEL=DEBUG "
    fi
    
    # Run MegaLinter in the current directory
    if ! megalinter_output=$(env "$megalinter_env" npx mega-linter-runner --path . 2>&1); then
        megalinter_exit_code=$?
        log_debug "MegaLinter exit code: $megalinter_exit_code"
        
        # Parse MegaLinter output for errors
        if [[ $megalinter_exit_code -ne 0 ]]; then
            # Check if there's a megalinter-reports directory with JSON output
            if [[ -f "megalinter-reports/megalinter-report.json" ]]; then
                parse_megalinter_json_report "megalinter-reports/megalinter-report.json"
            else
                # Fallback to parsing text output
                parse_megalinter_text_output "$megalinter_output"
            fi
        fi
        
        return $megalinter_exit_code
    fi
    
    return 0
}

# Parse MegaLinter JSON report for detailed error information
parse_megalinter_json_report() {
    local json_file="$1"
    
    if ! command_exists jq; then
        log_debug "jq not available, falling back to text parsing"
        return 1
    fi
    
    # Parse linter results from JSON
    local linter_results
    if linter_results=$(jq -r '.linters[] | select(.status == "error") | "\(.linter_name): \(.total_number_errors) errors"' "$json_file" 2>/dev/null); then
        if [[ -n "$linter_results" ]]; then
            while IFS= read -r line; do
                add_error "$line"
            done <<< "$linter_results"
        fi
    fi
}

# Parse MegaLinter text output for errors (fallback)
parse_megalinter_text_output() {
    local output="$1"
    
    # Look for error patterns in MegaLinter output
    if echo "$output" | grep -q "ERROR"; then
        # Extract error lines and add them to our error tracking
        local error_lines
        error_lines=$(echo "$output" | grep "ERROR" | head -10)
        while IFS= read -r line; do
            [[ -n "$line" ]] && add_error "MegaLinter: $line"
        done <<< "$error_lines"
    fi
    
    # Also check for linter-specific failure patterns
    if echo "$output" | grep -q "❌"; then
        add_error "MegaLinter found formatting or linting issues"
    fi
}

# ============================================================================
# PROJECT DETECTION
# ============================================================================

detect_project_type() {
    local project_type="unknown"
    local types=()
    
    # Go project
    if [[ -f "go.mod" ]] || [[ -f "go.sum" ]] || [[ -n "$(find . -maxdepth 3 -name "*.go" -type f -print -quit 2>/dev/null)" ]]; then
        types+=("go")
    fi
    
    # Python project
    if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "requirements.txt" ]] || [[ -n "$(find . -maxdepth 3 -name "*.py" -type f -print -quit 2>/dev/null)" ]]; then
        types+=("python")
    fi
    
    # JavaScript/TypeScript project
    if [[ -f "package.json" ]] || [[ -f "tsconfig.json" ]] || [[ -n "$(find . -maxdepth 3 \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -type f -print -quit 2>/dev/null)" ]]; then
        types+=("javascript")
    fi
    
    # Rust project
    if [[ -f "Cargo.toml" ]] || [[ -n "$(find . -maxdepth 3 -name "*.rs" -type f -print -quit 2>/dev/null)" ]]; then
        types+=("rust")
    fi
    
    # Nix project
    if [[ -f "flake.nix" ]] || [[ -f "default.nix" ]] || [[ -f "shell.nix" ]]; then
        types+=("nix")
    fi
    
    # Return primary type or "mixed" if multiple
    if [[ ${#types[@]} -eq 1 ]]; then
        project_type="${types[0]}"
    elif [[ ${#types[@]} -gt 1 ]]; then
        project_type="mixed:$(IFS=,; echo "${types[*]}")"
    fi
    
    log_debug "Detected project type: $project_type"
    echo "$project_type"
}

# shellcheck disable=SC2317 # Reserved for future use in file-specific linting
# Get list of modified files (if available from git)
get_modified_files() {
    if [[ -d .git ]] && command_exists git; then
        # Get files modified in the last commit or currently staged/modified
        git diff --name-only HEAD 2>/dev/null || true
        git diff --cached --name-only 2>/dev/null || true
    fi
}

# shellcheck disable=SC2317 # Reserved for future use in file-specific linting
# Check if we should skip a file
should_skip_file() {
    local file="$1"
    
    # Check .claude-hooks-ignore if it exists
    if [[ -f ".claude-hooks-ignore" ]]; then
        while IFS= read -r pattern; do
            # Skip comments and empty lines
            [[ -z "$pattern" || "$pattern" =~ ^[[:space:]]*# ]] && continue
            
            # Check if file matches pattern
            if [[ "$file" == "$pattern" ]]; then
                log_debug "Skipping $file due to .claude-hooks-ignore pattern: $pattern"
                return 0
            fi
        done < ".claude-hooks-ignore"
    fi
    
    # Check for inline skip comments
    if [[ -f "$file" ]] && head -n 5 "$file" 2>/dev/null | grep -q "claude-hooks-disable"; then
        log_debug "Skipping $file due to inline claude-hooks-disable comment"
        return 0
    fi
    
    return 1
}

# ============================================================================
# ERROR TRACKING
# ============================================================================

declare -a CLAUDE_HOOKS_SUMMARY=()
declare -i CLAUDE_HOOKS_ERROR_COUNT=0

add_error() {
    local message="$1"
    CLAUDE_HOOKS_ERROR_COUNT+=1
    CLAUDE_HOOKS_SUMMARY+=("${RED}❌${NC} $message")
}

print_summary() {
    if [[ $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
        # Only show failures when there are errors
        echo -e "\n${BLUE}═══ Summary ═══${NC}" >&2
        for item in "${CLAUDE_HOOKS_SUMMARY[@]}"; do
            echo -e "$item" >&2
        done
        
        echo -e "\n${RED}Found $CLAUDE_HOOKS_ERROR_COUNT issue(s) that MUST be fixed!${NC}" >&2
        echo -e "${RED}════════════════════════════════════════════${NC}" >&2
        echo -e "${RED}❌ ALL ISSUES ARE BLOCKING ❌${NC}" >&2
        echo -e "${RED}════════════════════════════════════════════${NC}" >&2
        echo -e "${RED}Fix EVERYTHING above until all checks are ✅ GREEN${NC}" >&2
    fi
}

# ============================================================================
# CONFIGURATION LOADING
# ============================================================================

load_config() {
    # Default configuration
    export CLAUDE_HOOKS_ENABLED="${CLAUDE_HOOKS_ENABLED:-true}"
    export CLAUDE_HOOKS_FAIL_FAST="${CLAUDE_HOOKS_FAIL_FAST:-false}"
    export CLAUDE_HOOKS_SHOW_TIMING="${CLAUDE_HOOKS_SHOW_TIMING:-false}"
    
    # Language enables
    export CLAUDE_HOOKS_GO_ENABLED="${CLAUDE_HOOKS_GO_ENABLED:-true}"
    export CLAUDE_HOOKS_PYTHON_ENABLED="${CLAUDE_HOOKS_PYTHON_ENABLED:-true}"
    export CLAUDE_HOOKS_JS_ENABLED="${CLAUDE_HOOKS_JS_ENABLED:-true}"
    export CLAUDE_HOOKS_RUST_ENABLED="${CLAUDE_HOOKS_RUST_ENABLED:-true}"
    export CLAUDE_HOOKS_NIX_ENABLED="${CLAUDE_HOOKS_NIX_ENABLED:-true}"
    
    # Project-specific overrides
    if [[ -f ".claude-hooks-config.sh" ]]; then
        # shellcheck source=/dev/null
        if ! source ".claude-hooks-config.sh"; then
            log_error "Failed to load .claude-hooks-config.sh - check for syntax errors"
            log_error "You can disable hooks by setting CLAUDE_HOOKS_ENABLED=false"
            exit 2
        fi
    fi
    
    # Quick exit if hooks are disabled
    if [[ "$CLAUDE_HOOKS_ENABLED" != "true" ]]; then
        log_info "Claude hooks are disabled"
        exit 0
    fi
}

# ============================================================================
# GO LINTING
# ============================================================================

lint_go() {
    if [[ "${CLAUDE_HOOKS_GO_ENABLED:-true}" != "true" ]]; then
        log_debug "Go linting disabled"
        return 0
    fi
    
    # Check if Makefile exists with fmt and lint targets - prefer those over MegaLinter
    if [[ -f "Makefile" ]]; then
        local has_fmt
        has_fmt=$(grep -E "^fmt:" Makefile 2>/dev/null || true)
        local has_lint
        has_lint=$(grep -E "^lint:" Makefile 2>/dev/null || true)
        
        if [[ -n "$has_fmt" && -n "$has_lint" ]]; then
            log_info "Using Makefile targets (preferred over MegaLinter)"
            
            local fmt_output
            if ! fmt_output=$(make fmt 2>&1); then
                add_error "Go formatting failed (make fmt)"
                echo "$fmt_output" >&2
            fi
            
            local lint_output
            if ! lint_output=$(make lint 2>&1); then
                add_error "Go linting failed (make lint)"
                echo "$lint_output" >&2
            fi
            return 0
        fi
    fi
    
    # Use MegaLinter for Go linting
    log_info "Running Go linting via MegaLinter..."
    run_megalinter "go"
}

# ============================================================================
# OTHER LANGUAGE LINTERS
# ============================================================================

lint_python() {
    if [[ "${CLAUDE_HOOKS_PYTHON_ENABLED:-true}" != "true" ]]; then
        log_debug "Python linting disabled"
        return 0
    fi
    
    # Use MegaLinter for Python linting
    log_info "Running Python linting via MegaLinter..."
    run_megalinter "python"
}

lint_javascript() {
    if [[ "${CLAUDE_HOOKS_JS_ENABLED:-true}" != "true" ]]; then
        log_debug "JavaScript linting disabled"
        return 0
    fi
    
    # Use MegaLinter for JavaScript/TypeScript linting
    log_info "Running JavaScript/TypeScript linting via MegaLinter..."
    run_megalinter "javascript"
}

lint_rust() {
    if [[ "${CLAUDE_HOOKS_RUST_ENABLED:-true}" != "true" ]]; then
        log_debug "Rust linting disabled"
        return 0
    fi
    
    # Use MegaLinter for Rust linting
    log_info "Running Rust linting via MegaLinter..."
    run_megalinter "rust"
}

lint_nix() {
    if [[ "${CLAUDE_HOOKS_NIX_ENABLED:-true}" != "true" ]]; then
        log_debug "Nix linting disabled"
        return 0
    fi
    
    log_info "Running Nix linters..."
    
    # Find all .nix files
    local nix_files
    nix_files=$(find . -name "*.nix" -type f | grep -v -E "(result/|/nix/store/)" | head -20)
    
    if [[ -z "$nix_files" ]]; then
        log_debug "No Nix files found"
        return 0
    fi
    
    # Check if we're already in a nix shell
    local in_nix_shell="${IN_NIX_SHELL:-0}"
    
    # Helper function to run command in nix shell if needed
    run_in_nix_shell() {
        local cmd="$1"
        local shell_type="${2:-nix}"
        
        if [[ "$in_nix_shell" != "0" ]] || command_exists "$cmd"; then
            # Already in nix shell or command exists locally
            return 0
        else
            # Try to run in nix shell
            if [[ -f "flake.nix" ]]; then
                log_info "Command '$cmd' not found, trying nix develop .#${shell_type}..."
                if nix develop ".#${shell_type}" --command bash -c "command -v '$cmd' >/dev/null 2>&1"; then
                    return 0
                else
                    return 1
                fi
            else
                return 1
            fi
        fi
    }
    
    # Check formatting with nixfmt-rfc-style (official RFC 166 formatter)
    if run_in_nix_shell nixfmt; then
        local fmt_output format_output
        if [[ "$in_nix_shell" != "0" ]] || command_exists nixfmt; then
            # Run locally
            if ! fmt_output=$(echo "$nix_files" | tr '\n' '\0' | xargs -0 nixfmt --check 2>&1); then
                if ! format_output=$(echo "$nix_files" | tr '\n' '\0' | xargs -0 nixfmt 2>&1); then
                    add_error "Nix formatting failed"
                    echo "$format_output" >&2
                fi
            fi
        else
            # Run in nix shell
            if ! fmt_output=$(nix develop .#nix --command bash -c "echo '$nix_files' | tr '\n' '\0' | xargs -0 nixfmt --check" 2>&1); then
                if ! format_output=$(nix develop .#nix --command bash -c "echo '$nix_files' | tr '\n' '\0' | xargs -0 nixfmt" 2>&1); then
                    add_error "Nix formatting failed"
                    echo "$format_output" >&2
                fi
            fi
        fi
    elif run_in_nix_shell nixpkgs-fmt; then
        local fmt_output format_output
        if [[ "$in_nix_shell" != "0" ]] || command_exists nixpkgs-fmt; then
            if ! fmt_output=$(echo "$nix_files" | xargs nixpkgs-fmt --check 2>&1); then
                if ! format_output=$(echo "$nix_files" | xargs nixpkgs-fmt 2>&1); then
                    add_error "Nix formatting failed"
                    echo "$format_output" >&2
                fi
            fi
        else
            if ! fmt_output=$(nix develop .#nix --command bash -c "echo '$nix_files' | xargs nixpkgs-fmt --check" 2>&1); then
                if ! format_output=$(nix develop .#nix --command bash -c "echo '$nix_files' | xargs nixpkgs-fmt" 2>&1); then
                    add_error "Nix formatting failed"
                    echo "$format_output" >&2
                fi
            fi
        fi
    elif run_in_nix_shell alejandra; then
        local fmt_output format_output
        if [[ "$in_nix_shell" != "0" ]] || command_exists alejandra; then
            if ! fmt_output=$(echo "$nix_files" | xargs alejandra --check 2>&1); then
                if ! format_output=$(echo "$nix_files" | xargs alejandra 2>&1); then
                    add_error "Nix formatting failed"
                    echo "$format_output" >&2
                fi
            fi
        else
            if ! fmt_output=$(nix develop .#nix --command bash -c "echo '$nix_files' | xargs alejandra --check" 2>&1); then
                if ! format_output=$(nix develop .#nix --command bash -c "echo '$nix_files' | xargs alejandra" 2>&1); then
                    add_error "Nix formatting failed"
                    echo "$format_output" >&2
                fi
            fi
        fi
    else
        add_error "No Nix formatter found (nixfmt, nixpkgs-fmt, or alejandra) - not available locally or in nix shell"
    fi
    
    # Static analysis with statix
    if run_in_nix_shell statix; then
        local statix_output
        if [[ "$in_nix_shell" != "0" ]] || command_exists statix; then
            if ! statix_output=$(statix check 2>&1); then
                add_error "Statix found issues"
                echo "$statix_output" >&2
            fi
        else
            if ! statix_output=$(nix develop .#nix --command statix check 2>&1); then
                add_error "Statix found issues"
                echo "$statix_output" >&2
            fi
        fi
    fi
    
    # Shell script validation with shellcheck
    local shell_files
    shell_files=$(find . -name "*.sh" -type f | grep -v -E "(result/|/nix/store/)" | head -20)
    
    if [[ -n "$shell_files" ]]; then
        if run_in_nix_shell shellcheck; then
            local shellcheck_output
            if [[ "$in_nix_shell" != "0" ]] || command_exists shellcheck; then
                if ! shellcheck_output=$(echo "$shell_files" | xargs shellcheck 2>&1); then
                    add_error "Shellcheck found issues in shell scripts"
                    echo "$shellcheck_output" >&2
                fi
            else
                if ! shellcheck_output=$(nix develop .#nix --command bash -c "echo '$shell_files' | xargs shellcheck" 2>&1); then
                    add_error "Shellcheck found issues in shell scripts"
                    echo "$shellcheck_output" >&2
                fi
            fi
        fi
    fi
    
    return 0
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            export CLAUDE_HOOKS_DEBUG=1
            shift
            ;;
        --fast)
            # Fast mode flag - currently unused but reserved for future use
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

# Load configuration
load_config

# Start timing
START_TIME=$(time_start)

# Detect project type
PROJECT_TYPE=$(detect_project_type)
log_info "Project type: $PROJECT_TYPE"

# Main execution
main() {
    # Separate MegaLinter-supported languages from Nix
    local megalinter_languages=""
    local has_nix=false
    local has_go_makefile=false
    
    # Check if Go has Makefile targets (prefer those over MegaLinter)
    if [[ "$PROJECT_TYPE" == *"go"* ]] && [[ -f "Makefile" ]]; then
        local has_fmt has_lint
        has_fmt=$(grep -E "^fmt:" Makefile 2>/dev/null || true)
        has_lint=$(grep -E "^lint:" Makefile 2>/dev/null || true)
        if [[ -n "$has_fmt" && -n "$has_lint" ]]; then
            has_go_makefile=true
        fi
    fi
    
    # Build list of languages for MegaLinter
    if [[ "$PROJECT_TYPE" == mixed:* ]]; then
        local project_types="${PROJECT_TYPE#mixed:}"
        IFS=',' read -ra TYPE_ARRAY <<< "$project_types"
        
        for type in "${TYPE_ARRAY[@]}"; do
            case "$type" in
                "go") 
                    if [[ "$has_go_makefile" != "true" && "${CLAUDE_HOOKS_GO_ENABLED:-true}" == "true" ]]; then
                        megalinter_languages+="go,"
                    fi
                    ;;
                "python") 
                    if [[ "${CLAUDE_HOOKS_PYTHON_ENABLED:-true}" == "true" ]]; then
                        megalinter_languages+="python,"
                    fi
                    ;;
                "javascript") 
                    if [[ "${CLAUDE_HOOKS_JS_ENABLED:-true}" == "true" ]]; then
                        megalinter_languages+="javascript,"
                    fi
                    ;;
                "rust") 
                    if [[ "${CLAUDE_HOOKS_RUST_ENABLED:-true}" == "true" ]]; then
                        megalinter_languages+="rust,"
                    fi
                    ;;
                "nix") 
                    has_nix=true
                    ;;
            esac
        done
    else
        # Single project type
        case "$PROJECT_TYPE" in
            "go") 
                if [[ "$has_go_makefile" != "true" && "${CLAUDE_HOOKS_GO_ENABLED:-true}" == "true" ]]; then
                    megalinter_languages="go"
                fi
                ;;
            "python") 
                if [[ "${CLAUDE_HOOKS_PYTHON_ENABLED:-true}" == "true" ]]; then
                    megalinter_languages="python"
                fi
                ;;
            "javascript") 
                if [[ "${CLAUDE_HOOKS_JS_ENABLED:-true}" == "true" ]]; then
                    megalinter_languages="javascript"
                fi
                ;;
            "rust") 
                if [[ "${CLAUDE_HOOKS_RUST_ENABLED:-true}" == "true" ]]; then
                    megalinter_languages="rust"
                fi
                ;;
            "nix") 
                has_nix=true
                ;;
            "unknown") 
                log_info "No recognized project type, skipping checks"
                ;;
        esac
    fi
    
    # Run MegaLinter for supported languages (more efficient than individual calls)
    if [[ -n "$megalinter_languages" ]]; then
        # Remove trailing comma
        megalinter_languages="${megalinter_languages%,}"
        log_info "Running MegaLinter for languages: $megalinter_languages"
        run_megalinter "$megalinter_languages"
        
        # Check for fail fast
        if [[ "$CLAUDE_HOOKS_FAIL_FAST" == "true" && $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
            time_end "$START_TIME"
            print_summary
            return 2
        fi
    fi
    
    # Handle Go with Makefile separately
    if [[ "$has_go_makefile" == "true" ]]; then
        lint_go
        if [[ "$CLAUDE_HOOKS_FAIL_FAST" == "true" && $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
            time_end "$START_TIME"
            print_summary
            return 2
        fi
    fi
    
    # Handle Nix separately (not supported by MegaLinter)
    if [[ "$has_nix" == "true" ]]; then
        lint_nix
    fi
    
    # Show timing if enabled
    time_end "$START_TIME"
    
    # Print summary
    print_summary
    
    # Return exit code - any issues mean failure
    if [[ $CLAUDE_HOOKS_ERROR_COUNT -gt 0 ]]; then
        return 2
    else
        return 0
    fi
}

# Run main function
main
exit_code=$?

# Final message and exit
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