#!/usr/bin/env bash
# @author Ramin Banihashemi <a@ramin.it>

# Carico utility per colorare le stringhe in bash
source "${base_dir}/lib/colorizer/colorizer.sh"

# Visualizzo l'output testuale
function show {
    colorize -n "${1}\n"
}

function showHelper {
    header="%-40s%-100s\n"
    colorize -n "$(printf "${header}" "${1}" "${2}")\n"
}
