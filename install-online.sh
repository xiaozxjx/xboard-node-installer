#!/usr/bin/env bash
#
# XBoard Node Installer
# Online Bootstrap Installer
#

set -o pipefail


#######################################
# Variables
#######################################

PROJECT="xiaozxjx/xboard-node-installer"

BRANCH="main"

TMP_DIR="/tmp/xboard-node-installer"



#######################################
# Colors
#######################################

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"



#######################################
# Log
#######################################

info()
{
    echo -e "${GREEN}[INFO]${RESET} $*"
}


error()
{
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}



#######################################
# Root Check
#######################################

if [ "$(id -u)" != "0" ]; then

    error "Please run as root"

    exit 1

fi



#######################################
# Dependency
#######################################

install_tools()
{

    if command -v curl >/dev/null 2>&1; then
        return
    fi


    if command -v apk >/dev/null 2>&1; then

        apk add curl tar gzip


    elif command -v apt-get >/dev/null 2>&1; then

        apt-get update

        apt-get install -y curl tar gzip


    fi

}



#######################################
# Download
#######################################

download_project()
{

    rm -rf "${TMP_DIR}"

    mkdir -p "${TMP_DIR}"


    info "Downloading installer..."



    curl -fsSL \
    "https://github.com/${PROJECT}/archive/refs/heads/${BRANCH}.tar.gz" \
    -o "${TMP_DIR}/project.tar.gz"



    tar -xzf \
    "${TMP_DIR}/project.tar.gz" \
    -C "${TMP_DIR}"



    mv \
    "${TMP_DIR}/${PROJECT##*/}-${BRANCH}" \
    "${TMP_DIR}/project"


}



#######################################
# Run Installer
#######################################

run_installer()
{

    cd "${TMP_DIR}/project"



    chmod +x install.sh



    info "Starting installer..."



    ./install.sh "$@"

}



#######################################
# Main
#######################################

main()
{

    install_tools


    download_project


    run_installer "$@"


}



main "$@"
