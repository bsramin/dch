#!/usr/bin/env bash
# @author Ramin Banihashemi <a@ramin.it>

if [ ! -f "$( cd "$( dirname "${BASH_SOURCE:-${0}}"/ )" && pwd )/../../project/.env" ]; then
    echo ""
    echo "Can't find .env file in the project directory!"
    echo "Please write a correct .env from .env.dist"
    echo ""
    exit
fi

# Carico le variabili di environment
set -a
. "$( cd "$( dirname "${BASH_SOURCE:-${0}}"/ )" && pwd )/../../project/.env"

