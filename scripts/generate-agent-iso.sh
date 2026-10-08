#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${1:-/root/ocp-4.22/abi-ocp-4.22.15}"

echo "Generating Agent-Based Installer ISO"
echo "Install directory: ${INSTALL_DIR}"

openshift-install agent create image --dir="${INSTALL_DIR}"

echo
echo "Generated ISO:"
ls -lh "${INSTALL_DIR}/agent.x86_64.iso"
