#!/usr/bin/env bash
#
# XBoard Node Installer
# Configuration Module
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

NODE_CONFIG_DIR="/etc/xboard-node"

NODE_CONFIG_FILE="${NODE_CONFIG_DIR}/config.yml"



#######################################
# Default Values
#######################################

PANEL_URL=""
NODE_TOKEN=""
MACHINE_ID=""



#######################################
# Parse Arguments
#######################################

parse_config_args()
{

    while [ $# -gt 0 ]; do

        case "$1" in


            --panel)

                PANEL_URL="$2"
                shift 2
                ;;


            --token)

                NODE_TOKEN="$2"
                shift 2
                ;;


            --machine-id)

                MACHINE_ID="$2"
                shift 2
                ;;


            *)

                shift
                ;;

        esac

    done

}



#######################################
# Interactive Input
#######################################

interactive_config()
{


    if [ -z "${PANEL_URL}" ]; then

        read -rp \
        "Panel URL: " \
        PANEL_URL

    fi



    if [ -z "${NODE_TOKEN}" ]; then

        read -rp \
        "Node Token: " \
        NODE_TOKEN

    fi



    if [ -z "${MACHINE_ID}" ]; then

        read -rp \
        "Machine ID: " \
        MACHINE_ID

    fi


}



#######################################
# Validate
#######################################

validate_config()
{

    if [ -z "${PANEL_URL}" ]; then

        die "Panel URL cannot be empty"

    fi



    if [ -z "${NODE_TOKEN}" ]; then

        die "Token cannot be empty"

    fi



    if [ -z "${MACHINE_ID}" ]; then

        die "Machine ID cannot be empty"

    fi



}



#######################################
# Create Config
#######################################

write_config()
{

    mkdir -p "${NODE_CONFIG_DIR}"



    backup_file "${NODE_CONFIG_FILE}"



    cat > "${NODE_CONFIG_FILE}" <<EOF
#
# XBoard Node Configuration
#

panel:
  url: ${PANEL_URL}

token: ${NODE_TOKEN}

machine_id: ${MACHINE_ID}

EOF



    chmod 600 "${NODE_CONFIG_FILE}"



    log_info "Configuration created:"
    log_info "${NODE_CONFIG_FILE}"

}



#######################################
# Show Config
#######################################

show_config()
{

    echo

    echo "=============================="
    echo "XBoard Node Config"
    echo "=============================="

    echo "Panel:"
    echo "${PANEL_URL}"

    echo "Machine ID:"
    echo "${MACHINE_ID}"

    echo "=============================="

    echo

}



#######################################
# Main
#######################################

create_config()
{

    parse_config_args "$@"

    interactive_config

    validate_config

    write_config

}



if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    create_config "$@"

fi
