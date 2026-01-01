#!/usr/bin/env bash

set -e          # Exit immediately if a command exits with a non-zero status
set -o pipefail # Prevent errors in a pipeline from being masked
set -u          # Treat unset variables as an error

# variables
pod_network_cidr=$1
interface_ip=$(ip route | grep default | head -n 1 | awk '{print $9}')

# packages
sudo dnf install -y 'dnf-command(versionlock)'
sudo dnf install -y kubeadm kubelet kubectl
sudo dnf versionlock add kubeadm kubelet kubectl

# services
sudo systemctl enable --now kubelet