#!/usr/bin/env bash
#
# XBoard Node Installer
# Update Module
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

NODE_BINARY="/usr/local/bin/xboard-node"

BACKUP_DIR="/var/backups/xboard-node"

TMP_DIR="/tmp/xboard-node-update"

SERVICE_SYSTEMD="${CURRENT_DIR}/service-systemd.sh"

SERVICE_OPENRC="${CURRENT_DIR}/service-openrc.sh"

SERVICE_NONE="${CURRENT_DIR}/service-none.sh"



#######################################
# Check Install
#######################################

check_install()
{

    if [ ! -f "${NODE_BINARY}" ]; then

        die "xboard-node is not installed"

    fi

}



#######################################
# Get Current Version
#######################################

get_current_version()
{

    if "${NODE_BINARY}" version >/dev/null 2>&1; then

        "${NODE_BINARY}" version 2>/dev/null

    else

        echo "unknown"

    fi

}



#######################################
# Restart Service
#######################################

restart_node()
{

    local init

    init="$(detect_init)"



    case "${init}" in


        systemd)

            systemctl restart xboard-node

            ;;


        openrc)

            rc-service xboard-node restart

            ;;


        *)

            "${SERVICE_NONE}" restart

            ;;


    esac

}



#######################################
# Update Binary
#######################################

update_binary()
{

    mkdir -p "${TMP_DIR}"


    detect_architecture



    log_info "Downloading latest xboard-node..."



    local file


    file=$(
        bash \
        "${CURRENT_DIR}/download.sh" \
        2>/dev/null
    )



    if [ ! -f "${file}" ]; then

        die "Download failed"

    fi



    backup_file "${NODE_BINARY}"



    cp \
        "${file}" \
        "${NODE_BINARY}"



    chmod +x "${NODE_BINARY}"



    log_info "Binary updated"

}



#######################################
# Main
#######################################

update_node()
{

    require_root


    check_install


    log_info "Current version:"

    get_current_version



    update_binary



    restart_node



    log_info "Update completed"

}



update_node
