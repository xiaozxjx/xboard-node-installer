#!/usr/bin/env bash
#
# XBoard Node Installer
# Uninstall Module
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

SERVICE_NAME="xboard-node"

NODE_BINARY="/usr/local/bin/xboard-node"

CONFIG_DIR="/etc/xboard-node"

LOG_DIR="/var/log/xboard-node"

BACKUP_DIR="/var/backups/xboard-node"



#######################################
# Stop Service
#######################################

stop_node()
{

    local init

    init="$(detect_init)"



    case "${init}" in


        systemd)

            if command_exists systemctl; then

                systemctl stop \
                    "${SERVICE_NAME}" \
                    2>/dev/null || true

            fi

            ;;


        openrc)

            if command_exists rc-service; then

                rc-service \
                    "${SERVICE_NAME}" \
                    stop \
                    2>/dev/null || true

            fi

            ;;


        *)

            "${CURRENT_DIR}/service-none.sh" stop \
                2>/dev/null || true

            ;;


    esac


}



#######################################
# Remove Service
#######################################

remove_service()
{

    local init

    init="$(detect_init)"



    case "${init}" in


        systemd)


            systemctl disable \
                "${SERVICE_NAME}" \
                2>/dev/null || true


            rm -f \
                "/etc/systemd/system/${SERVICE_NAME}.service"


            systemctl daemon-reload


            ;;



        openrc)


            rc-update del \
                "${SERVICE_NAME}" \
                default \
                2>/dev/null || true


            rm -f \
                "/etc/init.d/${SERVICE_NAME}"


            ;;



        *)

            ;;


    esac



    log_info "Service removed"

}



#######################################
# Backup Files
#######################################

backup_files()
{

    mkdir -p "${BACKUP_DIR}"



    if [ -f "${NODE_BINARY}" ]; then

        cp \
            "${NODE_BINARY}" \
            "${BACKUP_DIR}/xboard-node.binary.backup"

    fi



    if [ -d "${CONFIG_DIR}" ]; then

        cp -a \
            "${CONFIG_DIR}" \
            "${BACKUP_DIR}/config.backup"

    fi



    log_info "Backup saved:"
    log_info "${BACKUP_DIR}"

}



#######################################
# Remove Files
#######################################

remove_files()
{


    rm -f \
        "${NODE_BINARY}"



    rm -rf \
        "${CONFIG_DIR}"



    rm -rf \
        "${LOG_DIR}"



    log_info "Application files removed"

}



#######################################
# Confirm
#######################################

confirm_uninstall()
{

    echo

    echo "================================"

    echo "Remove XBoard Node?"

    echo "================================"

    echo


    read -rp \
    "Type YES to continue: " \
    answer



    if [ "${answer}" != "YES" ]; then

        echo "Cancelled"

        exit 0

    fi

}



#######################################
# Main
#######################################

uninstall()
{

    require_root


    confirm_uninstall


    stop_node


    backup_files


    remove_service


    remove_files



    log_info "XBoard Node uninstall completed"

}



uninstall
