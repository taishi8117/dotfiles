#!/bin/bash

NORMAL='\033[0m'
BOLD='\033[0;1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'


function log() {
  echo -e "[+] $@${NORMAL}"
}

function bold_log() {
  echo -e "${BOLD}[+] $@${NORMAL}"
}

function error_log() {
  echo -e "${RED}[!] $1${NORMAL}"
}

function ok_log() {
  echo -e "${GREEN}[+] $1${NORMAL}"
}
