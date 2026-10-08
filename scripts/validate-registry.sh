#!/usr/bin/env bash
set -euo pipefail

REGISTRY="${1:-registry.example.com:8443}"

echo "Checking registry: ${REGISTRY}"

curl -k -fsS "https://${REGISTRY}/v2/" >/dev/null

echo "Registry API is reachable."

podman ps || true
ss -lntp | grep 8443 || true
