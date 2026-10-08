#!/usr/bin/env bash
set -euo pipefail

echo "== DNS =="
systemctl is-active named
named-checkconf

echo "== NTP =="
systemctl is-active chronyd
chronyc tracking

echo "== HAProxy =="
systemctl is-active haproxy
haproxy -c -f /etc/haproxy/haproxy.cfg

echo "== Network =="
ip route
ss -lntp | grep -E ':(53|80|443|6443|22623|9000)' || true
