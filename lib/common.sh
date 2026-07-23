#!/bin/bash

msg(){
    echo "[INFO] $*"
}

err(){
    echo "[ERROR] $*" >&2
}

require_root(){
    [ "$(id -u)" = "0" ] || {
        err "Please run as root"
        exit 1
    }
}
