#!/usr/bin/env bash

nmcli con mod "Wired connection 1" ipv4.dns "8.8.8.8 8.8.4.4"
nmcli con mod "Wired connection 1" ipv4.ignore-auto-dns yes
nmcli con up "Wired connection 1"