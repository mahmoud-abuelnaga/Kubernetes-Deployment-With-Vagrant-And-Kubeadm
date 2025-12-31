#!/usr/bin/env bash

# variables
pod_network_cidr="192.168.0.0/16"
interface_ip=$(ip route | grep default | head -n 1 | awk '{print $9}')

# packages
sudo dnf install -y 'dnf-command(versionlock)'
sudo dnf install -y kubeadm kubelet kubectl
sudo dnf versionlock add kubeadm kubelet kubectl

# services
sudo systemctl enable --now kubelet

# kubeadm init
sudo kubeadm init \
  --pod-network-cidr="$pod_network_cidr" \
  --apiserver-advertise-address="$interface_ip" \
  --upload-certs | tee /tmp/kubeadm_init_output.txt > /dev/null

# join command
grep "kubeadm join" /tmp/kubeadm_init_output.txt > /tmp/join_command.txt

# kubectl config
echo "KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/environment