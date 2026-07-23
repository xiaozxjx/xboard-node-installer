#!/bin/bash

detect_init(){
    if command -v systemctl >/dev/null 2>&1; then
        echo systemd
    elif command -v rc-service >/dev/null 2>&1; then
        echo openrc
    else
        echo none
    fi
}

detect_arch(){
    uname -m
}
