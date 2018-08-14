#!/usr/bin/env bash
# @author Ramin Banihashemi <a@ramin.it>

return=

networkproxy="dch-reverse-proxy"

# Definisco il nome del container
function setImageName {
  container_name=$1
}

# Individuo il container dal nome
function getContainer {
  container=$(docker ps --all | grep ${docker_namespace}_${container_name} | awk {' print $NF '})
}

# Eseguo i comandi
function execute {
  exe=$1
  showExecute "$exe"
  eval $exe
}

function showExecute {
    exe=$1
    show "<purple>execute\x3E\x3E</purple> <cyan>$exe</cyan>";
}

# Visualizzo la lista dei containers attivi
function viewPs {
  execute "docker-compose ${composefiles} --project-name $docker_namespace ps"
}

# Visualizzo gli hostname dei container
function dockerhostname() {
    docker-compose $composefiles --project-name $docker_namespace ps | while read line; do
        if `echo $line | grep -q 'Name'`; then
            echo -e "Hostname"
        elif `echo $line | grep -q '\-\-'`; then
            echo -e "-------------"
        else
            CID=$(echo $line | awk '{print $1}');
            if ! [ -z "$CID" ]; then
                HOSTNAMECONTAINER=$(docker inspect --format="{{.Config.Hostname}}" ${CID});
                show "∙ $HOSTNAMECONTAINER"
            fi;
        fi;
    done;
    show " "
    if [ -n "$CID" ]; then
        show "<red>✗ No containers available</red>\n"
    fi
}

# Creo il network del reverse proxy
function createReverseNetwork() {
    hasnetwork=$(docker network ls | grep ${networkproxy})
    if [[ -z "$hasnetwork" ]]; then
        show "<yellow>Avvio il network</yellow>";
        execute "docker network create -d bridge --ipam-driver=default --subnet=172.77.1.1/24 ${networkproxy}"
    else
        show "<yellow>Network ${networkproxy} already exist</yellow>";
    fi
}

# Elimino il network del reverse proxy
function deleteReverseNetwork() {
    hasnetwork=$(docker network ls | grep ${networkproxy})
    if [[ -n "$hasnetwork" ]]; then
        show "<yellow>Remove ${networkproxy} network</yellow>";
        execute "docker network rm ${networkproxy}"
    fi
}

# Avvio il reverse proxy
function startReverseProxy() {
    checkcontainer=$(docker ps | grep ${networkproxy})
    if [[ -z "$checkcontainer" ]]; then
        show "<yellow>Start the reverse proxy</yellow>";
        execute "docker run --name ${networkproxy} -d -p 80:80 -p 443:443 -v /var/run/docker.sock:/tmp/docker.sock -t --net ${networkproxy} jwilder/nginx-proxy"
    else
        show "<yellow>Reverse proxy ${networkproxy} già avviato</yellow>";
    fi
}

# Fermo il reverse proxy
function stopReverseProxy() {
    container=$(docker ps --all | grep ${networkproxy} | awk {' print $1 '})
    if [[ -n "$container" ]]; then
        show "<yellow>Stop reverse proxy container ${networkproxy}</yellow>";
        execute "docker stop ${container}"
        execute "docker rm ${container}"
    fi
}

# Elimino il network del progetto
function deleteNetwork() {
    hasnetwork=$(docker network ls | grep ${docker_namespace}_network)
    if [[ -n "$hasnetwork" ]]; then
        show "<yellow>Remove ${docker_namespace}_network network</yellow>";
        execute "docker network rm ${docker_namespace}_network"
    fi
}

# Avvio i container
function goUp() {
    show "<yellow>Starting the containers</yellow>";

    createReverseNetwork

    if [ -z "$1" ] || [ "$1" != "1" ]; then
        # Scarico le ultime immagini
        execute "docker-compose ${composefiles} --project-name ${docker_namespace} pull"
        execute "docker-compose ${composefiles} --project-name ${docker_namespace} build --pull"
    fi

    # Avvio le immagini
    execute "docker-compose ${composefiles} --project-name ${docker_namespace} up --remove-orphans -d"

    startReverseProxy

    viewPs
    show "<green>✓ Done</green>";
}

# Fermo i container
function goDown() {
    show "<yellow>Stopping the containers</yellow>";

    # Fermo i container
    execute "docker-compose ${composefiles} --project-name ${docker_namespace} stop"

    viewPs
    show "<green>✓ Done</green>";
}

# Elimino container ed immagine
function killContainer {
    show "<yellow>Remove the containers</yellow>";
    execute "docker-compose $composefiles --project-name $docker_namespace rm --force"
    stoppedcontainers=$(docker ps -aq -f status=exited)

    if [ -n "$stoppedcontainers" ]; then
        execute "docker rm $stoppedcontainers"
    fi
    show "<green>✓ Done</green>";
}