#!/usr/bin/env bash
# docker-test.sh - Test dotfiles installation in Docker containers

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Test configurations
declare -A TEST_CONFIGS=(
    ["ubuntu-22.04"]="22.04"
    ["ubuntu-24.04"]="24.04"
    ["ubuntu-20.04"]="20.04"
)

# Default test configuration
DEFAULT_UBUNTU_VERSION="22.04"
DEFAULT_TEST_MODE="full"

# Global variables
UBUNTU_VERSION="$DEFAULT_UBUNTU_VERSION"
TEST_MODE="$DEFAULT_TEST_MODE"
CLEANUP=true
VERBOSE=false
PARALLEL=false

# Show help
show_help() {
    cat << 'EOF'
Docker Test Script for Dotfiles

USAGE:
    ./docker-test.sh [OPTIONS]

OPTIONS:
    --version VERSION   Ubuntu version to test (20.04, 22.04, 24.04)
    --mode MODE         Test mode (minimal, full, only)
    --component COMP    Test only specific component (requires --mode only)
    --all              Test all Ubuntu versions
    --parallel         Run tests in parallel
    --no-cleanup       Don't remove test containers
    --verbose          Verbose output
    --help             Show this help

EXAMPLES:
    ./docker-test.sh                           # Test Ubuntu 22.04 with full install
    ./docker-test.sh --version 24.04          # Test Ubuntu 24.04
    ./docker-test.sh --mode minimal           # Test minimal installation
    ./docker-test.sh --mode only --component zsh  # Test only zsh component
    ./docker-test.sh --all                    # Test all Ubuntu versions
    ./docker-test.sh --all --parallel         # Test all versions in parallel

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --version)
                if [[ $# -lt 2 ]]; then
                    log_error "--version requires a version number"
                    exit 1
                fi
                UBUNTU_VERSION="$2"
                shift 2
                ;;
            --mode)
                if [[ $# -lt 2 ]]; then
                    log_error "--mode requires a mode (minimal, full, only)"
                    exit 1
                fi
                TEST_MODE="$2"
                shift 2
                ;;
            --component)
                if [[ $# -lt 2 ]]; then
                    log_error "--component requires a component name"
                    exit 1
                fi
                COMPONENT="$2"
                shift 2
                ;;
            --all)
                TEST_ALL=true
                shift
                ;;
            --parallel)
                PARALLEL=true
                shift
                ;;
            --no-cleanup)
                CLEANUP=false
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Build test image
build_test_image() {
    local ubuntu_version="$1"
    local image_tag="dotfiles-test:ubuntu-${ubuntu_version}"

    log_info "Building test image for Ubuntu ${ubuntu_version}..."

    if [[ "$VERBOSE" == "true" ]]; then
        docker build \
            --build-arg UBUNTU_VERSION="$ubuntu_version" \
            -t "$image_tag" \
            -f Dockerfile.test \
            .
    else
        docker build \
            --build-arg UBUNTU_VERSION="$ubuntu_version" \
            -t "$image_tag" \
            -f Dockerfile.test \
            . > /dev/null 2>&1
    fi

    if [[ $? -eq 0 ]]; then
        log_success "Test image built: $image_tag"
        echo "$image_tag"
    else
        log_error "Failed to build test image for Ubuntu ${ubuntu_version}"
        return 1
    fi
}

# Run test in container
run_test() {
    local ubuntu_version="$1"
    local test_mode="$2"
    local component="${3:-}"

    log_info "Testing Ubuntu ${ubuntu_version} with mode: $test_mode${component:+ (component: $component)}"

    # Build image
    local image_tag
    if ! image_tag=$(build_test_image "$ubuntu_version"); then
        return 1
    fi

    # Prepare test command
    local test_cmd="./install.sh --${test_mode} --docker"
    if [[ "$test_mode" == "only" && -n "$component" ]]; then
        test_cmd="./install.sh --only $component --docker"
    fi

    # Generate container name
    local container_name="dotfiles-test-${ubuntu_version}-${test_mode}${component:+-$component}-$$"

    log_info "Running test container: $container_name"
    log_info "Command: $test_cmd"

    # Run test
    local start_time end_time duration
    start_time=$(date +%s)

    local test_result=0
    if [[ "$VERBOSE" == "true" ]]; then
        docker run --name "$container_name" "$image_tag" bash -c "$test_cmd"
        test_result=$?
    else
        docker run --name "$container_name" "$image_tag" bash -c "$test_cmd" > /dev/null 2>&1
        test_result=$?
    fi

    end_time=$(date +%s)
    duration=$((end_time - start_time))

    # Show results
    if [[ $test_result -eq 0 ]]; then
        log_success "Test passed for Ubuntu ${ubuntu_version} (${duration}s)"
    else
        log_error "Test failed for Ubuntu ${ubuntu_version} (${duration}s)"

        # Show container logs on failure
        if [[ "$VERBOSE" == "false" ]]; then
            log_info "Container logs:"
            docker logs "$container_name" 2>&1 | tail -20
        fi
    fi

    # Cleanup container
    if [[ "$CLEANUP" == "true" ]]; then
        docker rm "$container_name" > /dev/null 2>&1 || true
    else
        log_info "Container preserved: $container_name"
    fi

    return $test_result
}

# Test single configuration
test_single() {
    local ubuntu_version="$1"
    local test_mode="$2"
    local component="${3:-}"

    if run_test "$ubuntu_version" "$test_mode" "$component"; then
        return 0
    else
        return 1
    fi
}

# Test all Ubuntu versions
test_all_versions() {
    local test_mode="$1"
    local component="${2:-}"

    local failed_tests=()
    local pids=()

    for version_name in "${!TEST_CONFIGS[@]}"; do
        local version="${TEST_CONFIGS[$version_name]}"

        if [[ "$PARALLEL" == "true" ]]; then
            # Run in background
            (
                if run_test "$version" "$test_mode" "$component"; then
                    echo "SUCCESS:$version" > "/tmp/test_result_${version}_$$"
                else
                    echo "FAILED:$version" > "/tmp/test_result_${version}_$$"
                fi
            ) &
            pids+=($!)
        else
            # Run sequentially
            if ! run_test "$version" "$test_mode" "$component"; then
                failed_tests+=("$version")
            fi
        fi
    done

    # Wait for parallel tests to complete
    if [[ "$PARALLEL" == "true" ]]; then
        log_info "Waiting for parallel tests to complete..."

        for pid in "${pids[@]}"; do
            wait "$pid"
        done

        # Collect results
        for version_name in "${!TEST_CONFIGS[@]}"; do
            local version="${TEST_CONFIGS[$version_name]}"
            local result_file="/tmp/test_result_${version}_$$"

            if [[ -f "$result_file" ]]; then
                local result
                result=$(cat "$result_file")
                if [[ "$result" == "FAILED:$version" ]]; then
                    failed_tests+=("$version")
                fi
                rm -f "$result_file"
            else
                failed_tests+=("$version")
            fi
        done
    fi

    # Show summary
    echo
    log_info "=== Test Summary ==="
    local total=${#TEST_CONFIGS[@]}
    local passed=$((total - ${#failed_tests[@]}))

    log_info "Total tests: $total"
    log_success "Passed: $passed"

    if [[ ${#failed_tests[@]} -gt 0 ]]; then
        log_error "Failed: ${#failed_tests[@]} (${failed_tests[*]})"
        return 1
    else
        log_success "All tests passed! 🎉"
        return 0
    fi
}

# Cleanup old test images and containers
cleanup_old_tests() {
    log_info "Cleaning up old test containers and images..."

    # Remove old test containers
    docker ps -a --filter "name=dotfiles-test-" --format "{{.Names}}" | xargs -r docker rm > /dev/null 2>&1 || true

    # Remove old test images
    docker images "dotfiles-test" --format "{{.Repository}}:{{.Tag}}" | xargs -r docker rmi > /dev/null 2>&1 || true

    log_info "Cleanup completed"
}

# Pre-flight checks
preflight_checks() {
    # Check if Docker is available
    if ! command -v docker > /dev/null; then
        log_error "Docker is not installed or not in PATH"
        return 1
    fi

    # Check if Docker daemon is running
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker daemon is not running"
        return 1
    fi

    # Check if Dockerfile.test exists
    if [[ ! -f "Dockerfile.test" ]]; then
        log_error "Dockerfile.test not found in current directory"
        return 1
    fi

    log_success "Pre-flight checks passed"
}

# Main function
main() {
    log_info "=== Dotfiles Docker Test Runner ==="

    # Pre-flight checks
    preflight_checks || exit 1

    # Cleanup old tests
    cleanup_old_tests

    # Run tests
    if [[ "${TEST_ALL:-false}" == "true" ]]; then
        # Test all versions
        if test_all_versions "$TEST_MODE" "${COMPONENT:-}"; then
            log_success "All tests completed successfully!"
            exit 0
        else
            log_error "Some tests failed"
            exit 1
        fi
    else
        # Test single version
        if test_single "$UBUNTU_VERSION" "$TEST_MODE" "${COMPONENT:-}"; then
            log_success "Test completed successfully!"
            exit 0
        else
            log_error "Test failed"
            exit 1
        fi
    fi
}

# Parse arguments and run
parse_args "$@"
main