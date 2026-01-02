#!/usr/bin/env bash

set -e          # Exit immediately if a command exits with a non-zero status
set -o pipefail # Prevent errors in a pipeline from being masked
set -u          # Treat unset variables as an error

# variables
pod_network_cidr=$1

# firewall on host
cat <<EOF >/etc/firewalld/services/k8s-calico.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Calico</short>
  <description>Calico Networking for Kubernetes. Includes BGP, VXLAN, IP-in-IP, Typha, and Wireguard.</description>

  <port protocol="tcp" port="179"/>
  <port protocol="udp" port="4789"/>
  <port protocol="tcp" port="5473"/>
  <port protocol="udp" port="51820"/>
  <port protocol="udp" port="51821"/>
  <protocol value="4"/>
</service>
EOF

sudo firewall-cmd --reload
sudo firewall-cmd --permanent --add-service=k8s-calico
sudo firewall-cmd --reload

# Trust the pod network CIDR in firewall to allow pod-to-pod communication
sudo firewall-cmd --permanent --add-source="${pod_network_cidr}" --zone=trusted
sudo firewall-cmd --reload
