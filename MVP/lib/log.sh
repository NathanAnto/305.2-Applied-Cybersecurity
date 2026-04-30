#!/bin/bash

# Colour codes (disabled automatically if not a terminal)
if [[ -t 1 ]]; then
    _CLR_INFO="\033[0;32m"   # green
    _CLR_WARN="\033[0;33m"   # yellow
    _CLR_ERR="\033[0;31m"    # red
    _CLR_RESET="\033[0m"
else
    _CLR_INFO="" _CLR_WARN="" _CLR_ERR="" _CLR_RESET=""
fi

log_info()  { echo -e "${_CLR_INFO}[INFO]${_CLR_RESET}  $*"; }
log_warn()  { echo -e "${_CLR_WARN}[WARN]${_CLR_RESET}  $*" >&2; }
log_error() { echo -e "${_CLR_ERR}[ERROR]${_CLR_RESET} $*" >&2; }
