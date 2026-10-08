#!/usr/bin/env bash
set -euo pipefail

export KUBECONFIG="${KUBECONFIG:-/root/ocp-4.22/abi-ocp-4.22.15/auth/kubeconfig}"

echo "== Nodes =="
oc get nodes -o wide

echo
echo "== Cluster Version =="
oc get clusterversion

echo
echo "== Cluster Operators =="
oc get clusteroperators
