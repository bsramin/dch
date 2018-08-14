#!/usr/bin/env bash
# @author Ramin Banihashemi <a@ramin.it>

version="2.20180808"

OS=`uname -s`

cmd=$1
image_name=$2
base_dir="$( cd $(dirname "${BASH_SOURCE:-${0}}")"/../.." && pwd )"
docker_namespace=$(basename "${base_dir}")

if [ $OS != "Darwin" ]; then
    composefiles=" --file ${base_dir}/project/docker-compose.yml --file ${base_dir}/project/docker-compose.linux.yml"
else
    composefiles=" --file ${base_dir}/project/docker-compose.yml --file ${base_dir}/project/docker-compose.macos.yml"
fi