#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status
set -o pipefail # Prevent errors in a pipeline from being masked
set -u # Treat unset variables as an error when substituting

while [ ! -f /tmp/join_command.sh ]; do echo 'Waiting for join command...'; sleep 15; done
chmod +x /tmp/join_command.sh
sudo /tmp/join_command.sh
