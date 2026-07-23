#!/usr/bin/env bash
#
# XBoard Node Installer
#
# Universal Installer
#
# Support:
# Debian / Ubuntu / Alpine
# systemd / OpenRC / BusyBox
# ARM64 / AMD64
#

set -o pipefail


#######################################
# Path
#######################################

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LIB_DIR="${BASE_DIR}/lib"



#######################################
# Load Modules
#######################################

source "${LIB_DIR}/common.sh"

source "${LIB_DIR}/detect.sh"



#######################################
# Variables
#######################################

MODE="interactive"

PANEL=""

TOKEN=""

MACHINE_ID=""



#######################################
# Banner
#######################################

banner()
{

cat <<EOF

========================================

        XBoard Node Installer

        Version ${PROJECT_VERSION}

========================================

EOF

}



#######################################
# Arguments
#######################################

parse_args()
{

while [ $# -gt 0 ]
do

case "$1" in


--mode)

MODE="$2"
shift 2
;;


--panel)

PANEL="$2"
shift 2
;;


--token)

TOKEN="$2"
shift 2
;;


--machine-id)

MACHINE_ID="$2"
shift 2
;;


--debug)

DEBUG=1
shift
;;


-h|--help)

echo "
Usage:

Interactive:

 ./install.sh


Machine mode:

 ./install.sh \
 --mode machine \
 --panel URL \
 --token TOKEN \
 --machine-id ID

"

exit 0
;;


*)

shift
;;

esac

done

}



#######################################
# Install Dependency
#######################################

install_dependencies()
{


log_info "Checking dependencies"



if command_exists apk; then


    apk add \
    curl \
    wget \
    bash \
    ca-certificates \
    >/dev/null 2>&1 || true



elif command_exists apt-get; then


    apt-get update


    apt-get install -y \
    curl \
    wget \
    ca-certificates \
    bash



fi


}



#######################################
# Environment
#######################################

prepare_environment()
{

detect_all

print_detect_result


}



#######################################
# Download Node
#######################################

install_node()
{

source "${LIB_DIR}/download.sh"


download_and_install


}



#######################################
# Create Config
#######################################

create_node_config()
{


source "${LIB_DIR}/config.sh"


if [ "${MODE}" = "machine" ]; then


create_config \
--panel "${PANEL}" \
--token "${TOKEN}" \
--machine-id "${MACHINE_ID}"


else


create_config


fi


}



#######################################
# Install Service
#######################################

install_service()
{

case "${INIT_SYSTEM}" in


systemd)

    bash \
    "${LIB_DIR}/service-systemd.sh" \
    install


    bash \
    "${LIB_DIR}/service-systemd.sh" \
    start

;;


openrc)


    bash \
    "${LIB_DIR}/service-openrc.sh" \
    install


    bash \
    "${LIB_DIR}/service-openrc.sh" \
    start

;;



*)

    bash \
    "${LIB_DIR}/service-none.sh" \
    start

;;


esac

}



#######################################
# Health Check
#######################################

health_check()
{

bash \
"${LIB_DIR}/health.sh" \
|| true

}



#######################################
# Main
#######################################

main()
{

banner


require_root


parse_args "$@"


install_dependencies


prepare_environment


install_node


create_node_config


install_service


health_check



echo

log_info "Installation completed"

echo

}



main "$@"
