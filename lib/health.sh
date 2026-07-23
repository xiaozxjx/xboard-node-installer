#!/usr/bin/env bash
#
# XBoard Node Installer
# Health Check Module
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

NODE_CONFIG="/etc/xboard-node/config.yml"

SERVICE_NAME="xboard-node"

HEALTH_PORT=""



#######################################
# Result Counter
#######################################

CHECK_TOTAL=0

CHECK_PASS=0



#######################################
# Check Helper
#######################################

check_ok()
{

    CHECK_TOTAL=$((CHECK_TOTAL+1))

    CHECK_PASS=$((CHECK_PASS+1))

    echo -e "${C_GREEN}[ OK ]${C_RESET} $1"

}



check_fail()
{

    CHECK_TOTAL=$((CHECK_TOTAL+1))

    echo -e "${C_RED}[FAIL]${C_RESET} $1"

}



#######################################
# Check Binary
#######################################

check_binary()
{

    if [ -x "${NODE_BINARY}" ]; then

        check_ok "Binary exists"

    else

        check_fail "Binary missing"

    fi

}



#######################################
# Check Config
#######################################

check_config()
{

    if [ -f "${NODE_CONFIG}" ]; then

        check_ok "Configuration exists"

    else

        check_fail "Configuration missing"

    fi

}



#######################################
# Check Process
#######################################

check_process()
{

    if pgrep -f "xboard-node" >/dev/null 2>&1; then

        check_ok "Process running"

    else

        check_fail "Process not running"

    fi

}



#######################################
# Detect Service
#######################################

check_service()
{

    local init

    init="$(detect_init)"



    case "$init" in


        systemd)

            if systemctl is-active \
                --quiet \
                xboard-node; then

                check_ok "systemd service active"

            else

                check_fail "systemd service inactive"

            fi

            ;;


        openrc)

            if rc-service \
                xboard-node \
                status >/dev/null 2>&1; then

                check_ok "OpenRC service active"

            else

                check_fail "OpenRC service inactive"

            fi

            ;;


        *)

            check_ok "No service manager detected"

            ;;


    esac

}



#######################################
# Check Port
#######################################

check_port()
{

    if [ -z "${HEALTH_PORT}" ]; then

        return

    fi



    if command_exists ss; then


        if ss -lnt \
        | grep -q ":${HEALTH_PORT}"; then

            check_ok \
            "Health port ${HEALTH_PORT} listening"

        else

            check_fail \
            "Health port ${HEALTH_PORT} not listening"

        fi


    elif command_exists netstat; then


        if netstat -lnt \
        | grep -q ":${HEALTH_PORT}"; then

            check_ok \
            "Health port ${HEALTH_PORT} listening"

        else

            check_fail \
            "Health port ${HEALTH_PORT} not listening"

        fi


    fi

}



#######################################
# Summary
#######################################

summary()
{

    echo

    echo "================================"
    echo " Health Summary"
    echo "================================"

    echo "${CHECK_PASS}/${CHECK_TOTAL} checks passed"

    echo "================================"


    if [ "${CHECK_PASS}" = "${CHECK_TOTAL}" ]; then

        echo -e "${C_GREEN}HEALTHY${C_RESET}"

        return 0

    else

        echo -e "${C_RED}UNHEALTHY${C_RESET}"

        return 1

    fi

}



#######################################
# Main
#######################################

health_check()
{

    echo

    echo "================================"
    echo " XBoard Node Health Check"
    echo "================================"

    echo


    check_binary

    check_config

    check_process

    check_service

    check_port


    summary

}



if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    health_check

fi
