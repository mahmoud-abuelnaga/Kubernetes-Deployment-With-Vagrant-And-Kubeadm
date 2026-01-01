#!/usr/bin/env bash

set -e          # Exit immediately if a command exits with a non-zero status
set -o pipefail # Prevent errors in a pipeline from being masked
set -u          # Treat unset variables as an error

# load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf >/dev/null
br_netfilter
overlay
EOF

sudo modprobe br_netfilter
sudo modprobe overlay

# sysctl settings
cat <<EOF | sudo tee /etc/sysctl.d/00-k8s.conf >/dev/null
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1

fs.file-max = 2097152  # maximum number of open files
fs.inotify.max_user_watches = 1048576  # maximum number of inotify watches
fs.inotify.max_user_instances = 1024  # maximum number of inotify instances

net.netfilter.nf_conntrack_max = 1048576    # maximum number of active connections
net.core.somaxconn = 65535  # number of connections waiting to be accepted

net.ipv4.ip_local_port_range = 10240 65535  # range of ports for local connections
EOF

sudo sysctl --system

# ulimit settings
cat <<EOF | sudo tee /etc/security/limits.d/00-k8s.conf >/dev/null
* soft nofile 1048576
* hard nofile 1048576
* soft nproc  65536
* hard nproc  65536
EOF
