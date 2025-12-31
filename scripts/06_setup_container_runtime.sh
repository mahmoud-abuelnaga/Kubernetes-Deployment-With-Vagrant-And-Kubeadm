#!/usr/bin/env bash

# packages
sudo dnf install -y containerd.io

# configuration
sudo mkdir -p /etc/containerd
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml >/dev/null

# services
sudo systemctl enable --now containerd
sudo systemctl restart containerd