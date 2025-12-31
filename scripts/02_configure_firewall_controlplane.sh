#!/usr/bin/env bash

cat << EOF > /etc/firewalld/services/k8s-controlplane.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Kubernetes Control Plane</short>
  <description>Ports required for a Kubernetes Control Plane node (API Server, etcd, Kubelet, Scheduler, Controller Manager).</description>
  <port protocol="tcp" port="6443"/>
  <port protocol="tcp" port="2379-2380"/>
  <port protocol="tcp" port="10250"/>
  <port protocol="tcp" port="10259"/>
  <port protocol="tcp" port="10257"/>
</service>
EOF

sudo firewall-cmd --permanent --add-service=k8s-controlplane
sudo firewall-cmd --reload