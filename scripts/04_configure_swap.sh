#!/usr/bin/env bash

sed -i '/swap/d' /etc/fstab
sudo mount -a
sudo swapoff -a