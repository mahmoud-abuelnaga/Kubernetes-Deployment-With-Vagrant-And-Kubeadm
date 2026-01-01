#!/usr/bin/env bash

set -e          # Exit immediately if a command exits with a non-zero status
set -o pipefail # Prevent errors in a pipeline from being masked
set -u          # Treat unset variables as an error

cat <<EOF >/etc/firewalld/services/k8s-worker.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Kubernetes Worker</short>
  <description>Ports required for a Kubernetes Worker node</description>
  <port protocol="tcp" port="10250"/>
  <port protocol="tcp" port="30000-32767"/>
  <port protocol="udp" port="30000-32767"/>
</service>
EOF

sudo firewall-cmd --reload
sudo firewall-cmd --permanent --add-service=k8s-worker
sudo firewall-cmd --reload