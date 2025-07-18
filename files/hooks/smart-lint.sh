#!/usr/bin/env bash
# smart-lint.sh - MegaLinter wrapper for Claude Code

# Ensure claude-flake environment is loaded for MegaLinter access
if [[ -f "$HOME/.config/claude-flake/loader.sh" ]] && [[ -z "${CLAUDE_FLAKE_LOADED:-}" ]]; then
	# shellcheck source=/dev/null
	source "$HOME/.config/claude-flake/loader.sh" >/dev/null 2>&1 || true
fi
#
# SYNOPSIS
#   smart-lint.sh [options]
#
# DESCRIPTION
#   Runs MegaLinter for comprehensive multi-language linting. Maintains same exit codes.
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

# No color output to prevent ANSI escape sequence contamination
RED=''
YELLOW=''
BLUE=''
NC=''

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

		echo -e "\n${RED}Found issues that MUST be fixed!${NC}" >&2
		echo -e "${RED}════════════════════════════════════════════${NC}" >&2
		echo -e "${RED}❌ ALL ISSUES ARE BLOCKING ❌${NC}" >&2
		echo -e "${RED}════════════════════════════════════════════${NC}" >&2
		echo -e "${RED}Fix EVERYTHING above until all checks are ✅ GREEN${NC}" >&2
	fi
}

# Check if command exists
command_exists() {
	command -v "$1" &>/dev/null
}

# Detect project language based on files (adapted from cf script)
detect_project_language() {
	local current_dir
	current_dir="$(pwd)"

	# Check for language-specific files in order of specificity
	# Rust
	if [[ -f "${current_dir}/Cargo.toml" || -f "${current_dir}/Cargo.lock" ]]; then
		echo "rust"
		return 0
	fi

	# Go
	if [[ -f "${current_dir}/go.mod" || -f "${current_dir}/go.sum" ]]; then
		echo "go"
		return 0
	fi

	# Python
	if [[ -f "${current_dir}/pyproject.toml" || -f "${current_dir}/requirements.txt" ||
		-f "${current_dir}/poetry.lock" || -f "${current_dir}/setup.py" ||
		-f "${current_dir}/Pipfile" || -f "${current_dir}/environment.yml" ]]; then
		echo "python"
		return 0
	fi

	# Node.js
	if [[ -f "${current_dir}/package.json" || -f "${current_dir}/yarn.lock" ||
		-f "${current_dir}/package-lock.json" || -f "${current_dir}/pnpm-lock.yaml" ||
		-f "${current_dir}/bun.lockb" ]]; then
		echo "nodejs"
		return 0
	fi

	# Nix
	if [[ -f "${current_dir}/flake.nix" || -f "${current_dir}/shell.nix" ||
		-f "${current_dir}/default.nix" ]]; then
		echo "nix"
		return 0
	fi

	# Java
	if [[ -f "${current_dir}/pom.xml" || -f "${current_dir}/build.gradle" ||
		-f "${current_dir}/build.gradle.kts" || -f "${current_dir}/build.xml" ]]; then
		echo "java"
		return 0
	fi

	# C/C++
	if [[ -f "${current_dir}/CMakeLists.txt" || -f "${current_dir}/Makefile" ||
		-f "${current_dir}/configure" || -f "${current_dir}/meson.build" ]]; then
		echo "cpp"
		return 0
	fi

	# Default to universal if no specific language detected
	echo "universal"
}

# Map detected language to MegaLinter flavor
map_language_to_flavor() {
	local language="$1"

	case "$language" in
	"rust")
		echo "rust"
		;;
	"python")
		echo "python"
		;;
	"nodejs")
		echo "javascript"
		;;
	"go")
		echo "go"
		;;
	"java")
		echo "java"
		;;
	"cpp")
		echo "c_cpp"
		;;
	"nix" | "shell" | "universal" | *)
		echo "cupcake"
		;;
	esac
}

# Map detected language to MegaLinter ENABLE language name
map_language_to_megalinter_name() {
	local language="$1"

	case "$language" in
	"rust")
		echo "RUST"
		;;
	"python")
		echo "PYTHON"
		;;
	"nodejs")
		echo "JAVASCRIPT"
		;;
	"go")
		echo "GO"
		;;
	"java")
		echo "JAVA"
		;;
	"cpp")
		echo "C"
		;;
	"nix" | "shell" | "universal" | *)
		echo "" # For cupcake flavor, don't specify a single language
		;;
	esac
}

# Check if MegaLinter dependencies are available
megalinter_available() {
	command_exists npx && command_exists node && command_exists docker
}

# Run MegaLinter
run_megalinter() {

	# Detect project language first
	local detected_language
	detected_language=$(detect_project_language)

	# For Nix projects, use treefmt if available instead of MegaLinter
	if [[ "$detected_language" == "nix" ]]; then
		log_debug "Nix project detected - checking for treefmt"
		if command_exists treefmt; then
			log_info "Running treefmt for Nix project formatting..."
			if ! treefmt --fail-on-change 2>/dev/null; then
				add_error "treefmt found formatting issues"
			fi
			return 0
		elif command_exists nix && [[ -f "flake.nix" ]]; then
			log_info "Running nix fmt for Nix project formatting..."
			if ! nix fmt 2>/dev/null; then
				add_error "nix fmt found formatting issues"
			fi
			return 0
		else
			log_debug "No treefmt or nix fmt available, falling back to MegaLinter"
		fi
	fi

	if ! megalinter_available; then
		log_error "MegaLinter requirements not met - need npx, node, and docker"
		add_error "MegaLinter dependencies missing (install node, npx, docker)"
		return 1
	fi

	# Map to flavor and MegaLinter language name
	local flavor
	flavor=$(map_language_to_flavor "$detected_language")
	local megalinter_language
	megalinter_language=$(map_language_to_megalinter_name "$detected_language")

	log_info "Running MegaLinter with ${flavor} flavor (detected: ${detected_language}) - claude-flake ${VERSION}..."
	log_debug "Language detection: ${detected_language} → flavor: ${flavor}"

	# Set up environment variables for MegaLinter using -e flags
	local megalinter_env_flags=(
		"-e" "LOG_LEVEL=ERROR"
		"-e" "OUTPUT_DETAIL=simple"
		"-e" "PRINT_ALL_FILES=false"
		"-e" "CONSOLE_REPORTER_SECTIONS=false"
		"-e" "SHOW_ELAPSED_TIME=false"
		"-e" "SHOW_SKIPPED_LINTERS=false"
		"-e" "PRINT_ALPACA=false"
		"-e" "REPORT_OUTPUT_FOLDER=none"
		"-e" "TEXT_REPORTER=false"
		"-e" "TAP_REPORTER=false"
		"-e" "JSON_REPORTER=false"
		"-e" "CONFIG_REPORTER=false"
		"-e" "CONSOLE_REPORTER=true"
		"-e" "SHOW_ELAPSED_TIME=true"
		"-e" "PARALLEL=true"
		"-e" "PARALLEL_COUNT=4"
		"-e" "APPLY_FIXES=all"
		# Disabled due to limitations with running MegaLinter in Docker
		"-e" "PYTHON_PYLINT_ARGUMENTS=--disable=import-error"
		"-e" "'DISABLE_LINTERS=PYTHON_BANDIT,PYTHON_PYRIGHT'"
		# Ignore the usual directories
		"-e" "FILTER_REGEX_EXCLUDE=(result/|/nix/store/|\.git/|node_modules/|\.venv/|target/|\.mypy_cache/)"
	)

	# Add ENABLE language if specific language detected
	if [[ -n "$megalinter_language" ]]; then
		megalinter_env_flags+=("-e" "ENABLE=$megalinter_language")
		log_debug "Enabling specific language: $megalinter_language"
	fi

	if [[ "$DEBUG_MODE" == "1" ]]; then
		megalinter_env_flags+=("-e" "LOG_LEVEL=INFO")
	fi

	# Check if Docker image needs to be pulled (first run)
	local image_name="oxsecurity/megalinter-${flavor}:v8"
	if ! docker images | grep -q "oxsecurity/megalinter-${flavor}"; then
		log_info "First MegaLinter run - downloading ${flavor} image (this may take several minutes)..."
		if ! timeout 900 docker pull "$image_name" 2>/dev/null; then
			add_error "Failed to download MegaLinter ${flavor} image"
			return 1
		fi
	fi

	# Run MegaLinter with flavor and remove container flags
	log_debug "Running: npx mega-linter-runner --flavor $flavor --remove-container --path . ${megalinter_env_flags[*]}"
	timeout 600 npx mega-linter-runner --flavor "$flavor" --remove-container --path . "${megalinter_env_flags[@]}"
	local exit_code=$?
	log_debug "MegaLinter exit code: $exit_code"

	# Since we're not capturing output, we need to check exit code for errors
	local megalinter_output=""

	# Check exit code for errors (since we're not capturing output)
	if [[ $exit_code -ne 0 ]]; then
		add_error "MegaLinter found issues (exit code: $exit_code)"
		log_debug "MegaLinter completed with errors"
		return 1
	else
		log_debug "MegaLinter completed successfully"
		return 0
	fi
}

# Run shell script linting
run_shell_linting() {
	local shell_files
	shell_files=$(find . -name "*.sh" -type f | grep -v -E "(result/|/nix/store/)" | head -10)

	if [[ -n "$shell_files" ]] && command_exists shellcheck; then
		log_info "Running shellcheck on shell scripts..."
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

# Print header with version
VERSION=""
if [[ -f "$HOME/.config/claude-flake/VERSION" ]]; then
	VERSION=$(cat "$HOME/.config/claude-flake/VERSION" 2>/dev/null | tr -d '\n\r' || echo "unknown")
elif [[ -f "VERSION" ]]; then
	VERSION=$(cat "VERSION" 2>/dev/null | tr -d '\n\r' || echo "unknown")
else
	VERSION="unknown"
fi

echo "" >&2
echo "🔍 Style Check - Validating code formatting... (claude-flake $VERSION)" >&2
echo "─────────────────────────────────────────────────────────────────────" >&2

# Main execution
main() {
	# Run MegaLinter for supported languages
	run_megalinter

	# Run shell script linting separately
	run_shell_linting

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
