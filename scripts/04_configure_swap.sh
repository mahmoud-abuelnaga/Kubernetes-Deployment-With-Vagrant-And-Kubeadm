#!/usr/bin/env bash

set -e          # Exit immediately if a command exits with a non-zero status
set -o pipefail # Prevent errors in a pipeline from being masked
set -u          # Treat unset variables as an error

sed -i '/swap/d' /etc/fstab
sudo mount -a
sudo swapoff -a
