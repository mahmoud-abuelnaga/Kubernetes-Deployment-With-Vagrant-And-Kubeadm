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

# deploy calico
sudo dnf install -y wget
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/tigera-operator.yaml
while ! kubectl get pods -n tigera-operator | grep -i running; do
  echo "Waiting for tigera-operator to start..."
  echo "Sleeping for 10 seconds..."
  echo ""
  sleep 10
done

wget https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/custom-resources.yaml
sed -i "s|192.168.0.0/16|${pod_network_cidr}|" custom-resources.yaml
kubectl apply -f custom-resources.yaml

while kubectl get tigerastatus 2>&1 | grep -i "no resources found"; do
  echo "Waiting for tigerastatus to be available..."
  echo "Sleeping for 10 seconds..."
  echo ""
  sleep 10
done

while kubectl get tigerastatus | awk '{ print $2 }' | grep -i "false"; do
  echo "Waiting for calico setup to complete..."
  echo "Sleeping for 10 seconds..."
  echo ""
  sleep 10
done
