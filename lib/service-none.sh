#!/usr/bin/env bash
#
# XBoard Node Installer
# No Init System Service Module
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

NODE_CONFIG="/etc/xboard-node/config.yml"

RUN_DIR="/run/xboard-node"

PID_FILE="${RUN_DIR}/pid"

LOG_DIR="/var/log/xboard-node"

LOG_FILE="${LOG_DIR}/service.log"



#######################################
# Prepare
#######################################

prepare()
{

    mkdir -p \
        "${RUN_DIR}" \
        "${LOG_DIR}" \
        "/etc/xboard-node"

}



#######################################
# Start
#######################################

start_service()
{

    prepare


    if [ ! -x "${NODE_BINARY}" ]; then

        die "Binary not found: ${NODE_BINARY}"

    fi



    if [ -f "${PID_FILE}" ]; then

        if kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then

            log_warn "Service already running"

            return 0

        fi

    fi



    nohup \
    "${NODE_BINARY}" \
    -c "${NODE_CONFIG}" \
    >> "${LOG_FILE}" \
    2>&1 &



    echo $! > "${PID_FILE}"



    sleep 1



    if kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then

        log_info "Service started"

    else

        die "Failed to start service"

    fi

}



#######################################
# Stop
#######################################

stop_service()
{

    if [ ! -f "${PID_FILE}" ]; then

        log_warn "Service is not running"

        return 0

    fi



    PID="$(cat "${PID_FILE}")"



    if kill -0 "${PID}" 2>/dev/null; then

        kill "${PID}"

        sleep 2


        if kill -0 "${PID}" 2>/dev/null; then

            kill -9 "${PID}"

        fi

    fi



    rm -f "${PID_FILE}"


    log_info "Service stopped"

}



#######################################
# Restart
#######################################

restart_service()
{

    stop_service

    sleep 1

    start_service

}



#######################################
# Status
#######################################

status_service()
{

    if [ -f "${PID_FILE}" ]; then


        PID="$(cat "${PID_FILE}")"


        if kill -0 "${PID}" 2>/dev/null; then

            echo "xboard-node running"
            echo "PID: ${PID}"

            return 0

        fi

    fi


    echo "xboard-node stopped"

}



#######################################
# Logs
#######################################

logs_service()
{

    if [ -f "${LOG_FILE}" ]; then

        tail -f "${LOG_FILE}"

    else

        log_warn "No log file"

    fi

}



#######################################
# Remove
#######################################

remove_service()
{

    stop_service


    rm -rf "${RUN_DIR}"


    log_info "Service removed"

}



#######################################
# Command Router
#######################################

case "${1:-}" in


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
    echo "$0 {start|stop|restart|status|logs|remove}"

    ;;


esac
