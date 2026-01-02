#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status
set -o pipefail # Prevent errors in a pipeline from being masked
set -u # Treat unset variables as an error when substituting

sudo dnf install -y sshpass nmap-ncat

mkdir -p ~/.ssh/
[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q
while ! nc -z worker01 22; do echo "Waiting for worker01 to be reachable..."; sleep 15; done
ssh-keyscan -H worker01 >> ~/.ssh/known_hosts
sshpass -p 'vagrant' ssh-copy-id -o StrictHostKeyChecking=no vagrant@worker01
scp /tmp/join_command.sh vagrant@worker01:/tmp/join_command.sh
