#!/usr/bin/env bash
#
# XBoard Node Installer
# OpenRC Service Module
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

INIT_FILE="/etc/init.d/${SERVICE_NAME}"

NODE_BINARY="/usr/local/bin/xboard-node"

NODE_CONFIG="/etc/xboard-node/config.yml"



#######################################
# Check OpenRC
#######################################

require_openrc()
{

    if ! command_exists rc-service; then

        die "OpenRC is not installed"

    fi

}



#######################################
# Create Init Script
#######################################

create_init_script()
{

    require_openrc


    if [ ! -f "${NODE_BINARY}" ]; then

        die "Binary not found: ${NODE_BINARY}"

    fi



    cat > "${INIT_FILE}" <<EOF
#!/sbin/openrc-run

name="xboard-node"
description="XBoard Node Service"

command="${NODE_BINARY}"

command_args="-c ${NODE_CONFIG}"

command_user="root:root"

pidfile="/run/\${RC_SVCNAME}.pid"

command_background="yes"

output_log="/var/log/xboard-node/service.log"

error_log="/var/log/xboard-node/error.log"


depend()
{
    need net
}


start_pre()
{
    checkpath \
        --directory \
        --mode 0755 \
        /var/log/xboard-node

    checkpath \
        --directory \
        --mode 0755 \
        /etc/xboard-node
}

EOF


    chmod +x "${INIT_FILE}"


    log_info "OpenRC service created:"
    log_info "${INIT_FILE}"

}



#######################################
# Enable Service
#######################################

enable_service()
{

    rc-update add \
        "${SERVICE_NAME}" \
        default \
        2>/dev/null || true

}



#######################################
# Disable Service
#######################################

disable_service()
{

    rc-update del \
        "${SERVICE_NAME}" \
        default \
        2>/dev/null || true

}



#######################################
# Start
#######################################

start_service()
{

    rc-service \
        "${SERVICE_NAME}" \
        start

}



#######################################
# Stop
#######################################

stop_service()
{

    rc-service \
        "${SERVICE_NAME}" \
        stop

}



#######################################
# Restart
#######################################

restart_service()
{

    rc-service \
        "${SERVICE_NAME}" \
        restart

}



#######################################
# Status
#######################################

status_service()
{

    rc-service \
        "${SERVICE_NAME}" \
        status

}



#######################################
# Logs
#######################################

logs_service()
{

    if [ -f /var/log/xboard-node/service.log ]; then

        tail -f \
            /var/log/xboard-node/service.log

    else

        log_warn "No log file found"

    fi

}



#######################################
# Remove
#######################################

remove_service()
{

    stop_service || true

    disable_service || true


    rm -f "${INIT_FILE}"


    log_info "OpenRC service removed"

}



#######################################
# Command Router
#######################################

case "${1:-}" in


install)

    create_init_script
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
