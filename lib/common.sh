#!/usr/bin/env bash
#
# XBoard Node Installer
# Common Functions Library
#
# Compatible:
#   Debian / Ubuntu / Alpine
#   systemd / OpenRC / BusyBox
#

set -o pipefail


#######################################
# Project Information
#######################################

PROJECT_NAME="xboard-node-installer"
PROJECT_VERSION="1.0.0"

INSTALL_ROOT="/usr/local/xboard-node-installer"

CONFIG_DIR="/etc/xboard-node"
CONFIG_FILE="${CONFIG_DIR}/config.yml"

BIN_PATH="/usr/local/bin/xboard-node"

LOG_DIR="/var/log/xboard-node"
LOG_FILE="${LOG_DIR}/installer.log"

BACKUP_DIR="/var/backups/xboard-node"


#######################################
# Colors
#######################################

if [ -t 1 ]; then
    C_RED="\033[31m"
    C_GREEN="\033[32m"
    C_YELLOW="\033[33m"
    C_BLUE="\033[34m"
    C_RESET="\033[0m"
else
    C_RED=""
    C_GREEN=""
    C_YELLOW=""
    C_BLUE=""
    C_RESET=""
fi


#######################################
# Logging
#######################################

init_log()
{
    mkdir -p "$LOG_DIR" 2>/dev/null || true

    touch "$LOG_FILE" 2>/dev/null || true
}


_write_log()
{
    local level="$1"
    shift

    local msg="$*"

    echo "$(date '+%F %T') [$level] $msg" >> "$LOG_FILE" 2>/dev/null || true
}


log_info()
{
    echo -e "${C_GREEN}[INFO]${C_RESET} $*"
    _write_log INFO "$@"
}


log_warn()
{
    echo -e "${C_YELLOW}[WARN]${C_RESET} $*"
    _write_log WARN "$@"
}


log_error()
{
    echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2
    _write_log ERROR "$@"
}


log_debug()
{
    if [ "${DEBUG:-0}" = "1" ]; then
        echo -e "${C_BLUE}[DEBUG]${C_RESET} $*"
    fi

    _write_log DEBUG "$@"
}



#######################################
# Error Handling
#######################################

die()
{
    log_error "$@"
    exit 1
}


trap_error()
{
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        log_error "Command failed with exit code ${exit_code}"
    fi
}


trap trap_error EXIT



#######################################
# Permission
#######################################

require_root()
{
    if [ "$(id -u)" != "0" ]; then
        die "Please run this script as root"
    fi
}



#######################################
# Command Helpers
#######################################

command_exists()
{
    command -v "$1" >/dev/null 2>&1
}


require_command()
{
    if ! command_exists "$1"; then
        die "Required command not found: $1"
    fi
}



#######################################
# OS Information
#######################################

get_os()
{
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID}"
    else
        echo "unknown"
    fi
}


get_arch()
{
    case "$(uname -m)" in

        x86_64|amd64)
            echo "amd64"
            ;;

        aarch64|arm64)
            echo "arm64"
            ;;

        armv7l|armv7)
            echo "armv7"
            ;;

        *)
            echo "$(uname -m)"
            ;;
    esac
}



#######################################
# Network Helpers
#######################################

check_network()
{
    local host="${1:-github.com}"

    if command_exists curl; then

        curl \
            -fsSL \
            --connect-timeout 5 \
            "https://${host}" \
            >/dev/null 2>&1

        return $?

    elif command_exists wget; then

        wget \
            -q \
            --timeout=5 \
            -O /dev/null \
            "https://${host}"

        return $?

    else

        return 1

    fi
}



#######################################
# Download Helpers
#######################################

download_file()
{
    local url="$1"
    local output="$2"


    log_info "Downloading:"
    log_info "$url"


    mkdir -p "$(dirname "$output")"


    if command_exists curl; then

        curl \
            -fL \
            --retry 3 \
            -o "$output" \
            "$url"

    elif command_exists wget; then

        wget \
            -O "$output" \
            "$url"

    else

        die "curl or wget is required"

    fi


    if [ ! -s "$output" ]; then
        die "Download failed: $output"
    fi


    chmod +x "$output"

}



#######################################
# File Helpers
#######################################

ensure_dir()
{
    mkdir -p "$1"
}


backup_file()
{
    local file="$1"


    if [ -f "$file" ]; then

        mkdir -p "$BACKUP_DIR"

        cp \
            "$file" \
            "${BACKUP_DIR}/$(basename "$file").$(date +%s).bak"

        log_info "Backup created:"
        log_info "$file"

    fi
}



safe_write()
{
    local file="$1"

    local tmp

    tmp="$(mktemp)"


    cat > "$tmp"


    mkdir -p "$(dirname "$file")"

    mv "$tmp" "$file"

}



#######################################
# Service Helpers
#######################################

detect_init()
{
    if command_exists systemctl; then
        echo "systemd"

    elif command_exists rc-service; then
        echo "openrc"

    elif [ -x /sbin/init ]; then
        echo "busybox"

    else
        echo "none"
    fi
}



#######################################
# Environment Summary
#######################################

show_environment()
{
    echo
    echo "================================"
    echo " Environment"
    echo "================================"

    echo "OS:"
    get_os

    echo "Architecture:"
    get_arch

    echo "Init:"
    detect_init

    echo "Kernel:"
    uname -r

    echo "================================"
    echo
}



#######################################
# Initialization
#######################################

common_init()
{
    init_log

    log_debug "Project:"
    log_debug "$PROJECT_NAME"

    log_debug "Version:"
    log_debug "$PROJECT_VERSION"
}


# Auto init when sourced
common_init
