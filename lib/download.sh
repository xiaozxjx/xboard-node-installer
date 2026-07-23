#!/usr/bin/env bash
#
# XBoard Node Installer
# Download Module
#

set -o pipefail


#######################################
# Load common
#######################################

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${CURRENT_DIR}/common.sh"



#######################################
# Variables
#######################################

XB_NODE_NAME="xboard-node"

XB_GITHUB_REPO="cedar2025/xboard-node"

XB_RELEASE_API="https://api.github.com/repos/${XB_GITHUB_REPO}/releases/latest"

DOWNLOAD_DIR="/tmp/xboard-node-download"



#######################################
# Detect latest version
#######################################

get_latest_version()
{

    log_info "Checking latest xboard-node version..."


    if ! command_exists curl; then

        die "curl is required"

    fi


    VERSION=$(curl -fsSL "${XB_RELEASE_API}" \
        | grep '"tag_name"' \
        | head -1 \
        | cut -d '"' -f4)



    if [ -z "${VERSION}" ]; then

        die "Unable to get latest version"

    fi


    echo "${VERSION}"

}



#######################################
# Get Release URL
#######################################

get_download_url()
{

    local arch="$1"

    local json


    json=$(curl -fsSL "${XB_RELEASE_API}")


    if [ -z "$json" ]; then

        die "Cannot access GitHub API"

    fi



    case "$arch" in


        amd64)

            echo "$json" \
            | grep browser_download_url \
            | grep -Ei 'amd64|x86_64' \
            | head -1 \
            | cut -d '"' -f4

            ;;


        arm64)

            echo "$json" \
            | grep browser_download_url \
            | grep -Ei 'arm64|aarch64' \
            | head -1 \
            | cut -d '"' -f4

            ;;


        armv7)

            echo "$json" \
            | grep browser_download_url \
            | grep -Ei 'armv7|arm' \
            | head -1 \
            | cut -d '"' -f4

            ;;


        *)

            die "Unsupported architecture: ${arch}"

            ;;


    esac

}



#######################################
# Download binary
#######################################

download_xboard_node()
{

    mkdir -p "${DOWNLOAD_DIR}"


    local version
    local url


    version=$(get_latest_version)


    log_info "Latest version: ${version}"


    url=$(get_download_url "${ARCH}")


    if [ -z "$url" ]; then

        die "No matching binary found for ${ARCH}"

    fi


    log_info "Download URL:"
    log_info "${url}"



    local file

    file="${DOWNLOAD_DIR}/${XB_NODE_NAME}"



    download_file \
        "${url}" \
        "${file}"



    chmod +x "${file}"


    echo "${file}"

}



#######################################
# Install binary
#######################################

install_binary()
{

    local file="$1"


    if [ ! -f "$file" ]; then

        die "Binary not found: $file"

    fi



    backup_file "${BIN_PATH}"



    mkdir -p "$(dirname "${BIN_PATH}")"



    cp \
        "${file}" \
        "${BIN_PATH}"



    chmod +x "${BIN_PATH}"



    log_info "Installed:"
    log_info "${BIN_PATH}"

}



#######################################
# Main
#######################################

download_and_install()
{

    detect_architecture >/dev/null 2>&1 || true


    local file

    file=$(download_xboard_node)


    install_binary "${file}"

}



if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    download_and_install

fi
