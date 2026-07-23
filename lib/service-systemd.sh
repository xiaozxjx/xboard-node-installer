#!/usr/bin/env bash
#
# XBoard Node Installer
# systemd Service Module
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

SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

SERVICE_USER="root"

NODE_BINARY="/usr/local/bin/xboard-node"

NODE_CONFIG="/etc/xboard-node/config.yml"



#######################################
# Check systemd
#######################################

require_systemd()
{

    if ! command_exists systemctl; then

        die "systemd is not available"

    fi

}



#######################################
# Create service
#######################################

create_service()
{

    require_systemd


    if [ ! -f "${NODE_BINARY}" ]; then

        die "Binary not found: ${NODE_BINARY}"

    fi



    mkdir -p "$(dirname "${NODE_CONFIG}")"



    cat > "${SERVICE_FILE}" <<EOF
[Unit]
Description=XBoard Node Service
Documentation=https://github.com/cedar2025/xboard-node
After=network-online.target
Wants=network-online.target


[Service]
Type=simple
User=${SERVICE_USER}

ExecStart=${NODE_BINARY} -c ${NODE_CONFIG}

Restart=always
RestartSec=5

LimitNOFILE=65535


[Install]
WantedBy=multi-user.target
EOF



    systemctl daemon-reload


    log_info "systemd service created:"
    log_info "${SERVICE_FILE}"

}



#######################################
# Enable
#######################################

enable_service()
{

    systemctl enable "${SERVICE_NAME}"


}



#######################################
# Disable
#######################################

disable_service()
{

    systemctl disable "${SERVICE_NAME}" 2>/dev/null || true

}



#######################################
# Start
#######################################

start_service()
{

    systemctl start "${SERVICE_NAME}"

    log_info "Service started"

}



#######################################
# Stop
#######################################

stop_service()
{

    systemctl stop "${SERVICE_NAME}"

}



#######################################
# Restart
#######################################

restart_service()
{

    systemctl restart "${SERVICE_NAME}"

    log_info "Service restarted"

}



#######################################
# Status
#######################################

status_service()
{

    systemctl status \
        "${SERVICE_NAME}" \
        --no-pager

}



#######################################
# Logs
#######################################

logs_service()
{

    journalctl \
        -u "${SERVICE_NAME}" \
        -f

}



#######################################
# Remove
#######################################

remove_service()
{

    stop_service || true

    disable_service || true


    rm -f "${SERVICE_FILE}"


    systemctl daemon-reload


    log_info "systemd service removed"

}



#######################################
# Command Router
#######################################

case "${1:-}" in


    install)

        create_service
        enable_service
        ;;


    start)

        start_service
        ;;


    stop)

        stop_service
        ;;


    restart)

        restart_service
        ;;


    status)

        status_service
        ;;


    logs)

        logs_service
        ;;


    remove)

        remove_service
        ;;


    *)

        echo "Usage:"
        echo "$0 {install|start|stop|restart|status|logs|remove}"

        ;;


esac
