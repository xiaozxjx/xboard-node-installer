#!/usr/bin/env bash
#
# XBoard Node Installer
# System Detection Module
#

set -o pipefail


#######################################
# Load common module
#######################################

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "${CURRENT_DIR}/common.sh" ]; then
    source "${CURRENT_DIR}/common.sh"
fi



#######################################
# Detect OS
#######################################

detect_os()
{
    OS_ID="unknown"
    OS_VERSION="unknown"
    OS_NAME="unknown"


    if [ -f /etc/os-release ]; then

        source /etc/os-release

        OS_ID="${ID:-unknown}"
        OS_VERSION="${VERSION_ID:-unknown}"
        OS_NAME="${PRETTY_NAME:-unknown}"

    fi


    export OS_ID
    export OS_VERSION
    export OS_NAME
}



#######################################
# Detect Architecture
#######################################

detect_architecture()
{
    local arch

    arch="$(uname -m)"


    case "$arch" in

        x86_64|amd64)

            ARCH="amd64"
            ;;


        aarch64|arm64)

            ARCH="arm64"
            ;;


        armv7l|armv7)

            ARCH="armv7"
            ;;


        i386|i686)

            ARCH="386"
            ;;


        *)

            ARCH="$arch"
            ;;

    esac


    export ARCH
}



#######################################
# Detect Init System
#######################################

detect_init_system()
{

    INIT_SYSTEM="none"


    # systemd

    if command -v systemctl >/dev/null 2>&1 \
       && [ -d /run/systemd/system ]; then


        INIT_SYSTEM="systemd"


    # OpenRC

    elif command -v rc-service >/dev/null 2>&1; then


        INIT_SYSTEM="openrc"


    # BusyBox init

    elif [ -x /bin/busybox ] \
         && ps -p 1 -o comm= | grep -qi init; then


        INIT_SYSTEM="busybox"


    # SysV

    elif [ -d /etc/init.d ]; then


        INIT_SYSTEM="sysv"


    fi


    export INIT_SYSTEM
}



#######################################
# Detect Virtualization
#######################################

detect_virtualization()
{

    VIRT="none"


    if command -v systemd-detect-virt >/dev/null 2>&1; then

        VIRT="$(systemd-detect-virt 2>/dev/null || echo none)"


    elif [ -f /proc/vz/veinfo ]; then

        VIRT="openvz"


    elif grep -qa docker /proc/1/cgroup 2>/dev/null; then

        VIRT="docker"


    elif grep -qa lxc /proc/1/cgroup 2>/dev/null; then

        VIRT="lxc"

    fi


    export VIRT
}



#######################################
# Detect Kernel
#######################################

detect_kernel()
{
    KERNEL_VERSION="$(uname -r)"

    export KERNEL_VERSION
}



#######################################
# Run Detection
#######################################

detect_all()
{
    detect_os
    detect_architecture
    detect_init_system
    detect_virtualization
    detect_kernel
}



#######################################
# Print Result
#######################################

print_detect_result()
{

    echo
    echo "======================================"
    echo " XBoard Node Environment"
    echo "======================================"

    echo "OS:"
    echo "  ${OS_NAME}"

    echo "Version:"
    echo "  ${OS_VERSION}"

    echo "Architecture:"
    echo "  ${ARCH}"

    echo "Init:"
    echo "  ${INIT_SYSTEM}"

    echo "Virtualization:"
    echo "  ${VIRT}"

    echo "Kernel:"
    echo "  ${KERNEL_VERSION}"

    echo "======================================"
    echo

}



#######################################
# Auto execute when run directly
#######################################

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    detect_all
    print_detect_result

fi
