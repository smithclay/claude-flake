#!/usr/bin/env bash

# Claude-Flake Performance Benchmark Script
# Phase 3B Task 11: Measure current performance baseline

set -euo pipefail

# Configuration
RESULTS_FILE="performance-results.json"

# System detection
detect_system() {
    local system=""
    case "$(uname -s)" in
        Linux*)
            case "$(uname -m)" in
                x86_64) system="x86_64-linux" ;;
                aarch64) system="aarch64-linux" ;;
                *) system="unknown-linux" ;;
            esac
            ;;
        Darwin*)
            case "$(uname -m)" in
                x86_64) system="x86_64-darwin" ;;
                arm64) system="aarch64-darwin" ;;
                *) system="unknown-darwin" ;;
            esac
            ;;
        *) system="unknown" ;;
    esac
    echo "$system"
}

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

# Time a command and return the duration in seconds
time_command() {
    local cmd="$1"
    local description="$2"
    
    log "Timing: $description"
    
    local start_time
    start_time=$(date +%s.%N)
    
    # Execute command with timeout
    if timeout 60 bash -c "eval '$cmd'" >/dev/null 2>&1; then
        local end_time
        end_time=$(date +%s.%N)
        local duration
        duration=$(awk "BEGIN {printf \"%.3f\", $end_time - $start_time}")
        log "Completed in ${duration}s"
        echo "$duration"
    else
        log "Command failed or timed out: $cmd"
        echo "0"
    fi
}

# Get system resource usage
get_system_stats() {
    local phase="$1"
    
    log "Collecting system stats for: $phase"
    
    local memory_mb
    memory_mb=$(free -m | awk '/^Mem:/{print $3}' 2>/dev/null || echo '0')
    local disk_gb
    disk_gb=$(df -BG /nix/store 2>/dev/null | awk 'NR==2{print $3}' | sed 's/G//' || echo '0')
    local load_avg
    load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^[[:space:]]*//' || echo 'N/A')
    
    cat <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "phase": "$phase",
    "memory_usage_mb": $memory_mb,
    "disk_usage_gb": $disk_gb,
    "load_average": "$load_avg"
}
EOF
}

# Clear nix cache to test cold start
clear_cache() {
    log "Clearing nix cache for cold start test"
    
    # Clear various caches
    nix-collect-garbage -d >/dev/null 2>&1 || true
    nix store gc >/dev/null 2>&1 || true
    
    # Clear home-manager cache if it exists
    if [ -d "$HOME/.cache/nix" ]; then
        rm -rf "$HOME/.cache/nix" 2>/dev/null || true
    fi
    
    log "Cache cleared"
}

# Test cache effectiveness
test_cache_effectiveness() {
    log "Testing cache effectiveness"
    
    # Cold start test
    log "Testing cold start performance..."
    clear_cache
    local cold_start_time
    cold_start_time=$(time_command "nix flake show --no-write-lock-file ." "Cold start - flake show")
    
    # Warm start test
    log "Testing warm start performance..."
    local warm_start_time
    warm_start_time=$(time_command "nix flake show --no-write-lock-file ." "Warm start - flake show")
    
    # Calculate cache improvement
    local improvement="0"
    if [ "$cold_start_time" != "0" ] && [ "$warm_start_time" != "0" ]; then
        improvement=$(awk "BEGIN {printf \"%.2f\", ($cold_start_time - $warm_start_time) / $cold_start_time * 100}")
    fi
    
    log "Cache effectiveness: ${improvement}% improvement"
    
    cat <<EOF
{
    "cold_start_seconds": $cold_start_time,
    "warm_start_seconds": $warm_start_time,
    "improvement_percent": $improvement
}
EOF
}

# Benchmark specific claude-flake operations
benchmark_operations() {
    log "Benchmarking claude-flake operations"
    
    # Test operations individually
    local op1
    op1=$(time_command "nix flake check --no-write-lock-file ." "Flake check")
    local op2
    op2=$(time_command "nix flake show --no-write-lock-file ." "Flake show")
    local op3
    op3=$(time_command "nix build .#homeConfigurations.\"user@linux\".activationPackage --no-link" "Build activation package")
    
    # Calculate average of successful operations
    local operations=("$op1" "$op2" "$op3")
    local total=0
    local count=0
    
    for op in "${operations[@]}"; do
        if [ "$op" != "0" ]; then
            total=$(awk "BEGIN {print $total + $op}")
            count=$((count + 1))
        fi
    done
    
    local average=0
    if [ "$count" -gt 0 ]; then
        average=$(awk "BEGIN {printf \"%.2f\", $total / $count}")
    fi
    
    cat <<EOF
{
    "flake_check_seconds": $op1,
    "flake_show_seconds": $op2,
    "build_activation_seconds": $op3,
    "average_seconds": $average,
    "successful_operations": $count
}
EOF
}

# Run full benchmark suite
run_benchmark() {
    local system="$1"
    
    log "Starting benchmark for system: $system"
    
    # Collect initial system stats
    local initial_stats
    initial_stats=$(get_system_stats "initial")
    
    # Test cache effectiveness
    local cache_stats
    cache_stats=$(test_cache_effectiveness)
    
    # Benchmark operations
    local operation_stats
    operation_stats=$(benchmark_operations)
    
    # Collect final system stats
    local final_stats
    final_stats=$(get_system_stats "final")
    
    # Compile results
    cat <<EOF
{
    "system": "$system",
    "benchmark_time": "$(date -Iseconds)",
    "initial_stats": $initial_stats,
    "final_stats": $final_stats,
    "cache_effectiveness": $cache_stats,
    "operations": $operation_stats
}
EOF
}

# Main execution
main() {
    log "Claude-Flake Performance Benchmark"
    log "================================="
    
    # Detect system
    local system
    system=$(detect_system)
    log "Detected system: $system"
    
    # Check prerequisites
    if ! command -v nix >/dev/null 2>&1; then
        log "ERROR: Nix is not installed or not in PATH"
        exit 1
    fi
    
    # Run benchmark
    log "Starting benchmark run..."
    local results
    results=$(run_benchmark "$system")
    
    # Save results
    echo "$results" > "$RESULTS_FILE"
    log "Results saved to: $RESULTS_FILE"
    
    # Display summary
    log "Benchmark Summary:"
    if command -v jq >/dev/null 2>&1; then
        echo "$results" | jq -r '
            "System: " + .system + 
            "\nCache Improvement: " + (.cache_effectiveness.improvement_percent | tostring) + "%" +
            "\nAverage Operation Time: " + (.operations.average_seconds | tostring) + "s" +
            "\nSuccessful Operations: " + (.operations.successful_operations | tostring)
        '
    else
        log "jq not available, displaying raw results:"
        echo "$results" | head -20
    fi
    
    log "Benchmark completed successfully!"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi