# Install OpenShift 4.22 Disconnected ABI

This repository documents a lab installation of OpenShift Container Platform 4.22 using the Agent-Based Installer (ABI) in a disconnected environment.

The documentation is written as a practical, command-by-command installation guide. Replace all example values with the values from your own environment.

## Lab Architecture

| Hostname | IP address | Description | Hardware Requirement |
| :--- | :--- | :--- | :--- |
| `bastion.example.com` | `192.0.2.10` | Bastion / Helper Node | 16 GB RAM - 60 GB HDD - 4 CPU |
| `registry.example.com` | `192.0.2.20` | Mirror Registry | 6+ GB RAM - 100+ GB storage |
| `master1.example.com` | `198.51.100.11` | Master Node | 16 GB RAM - 60+ GB HDD - 4 CPU |
| `master2.example.com` | `198.51.100.12` | Master Node | 16 GB RAM - 60+ GB HDD - 4 CPU |
| `master3.example.com` | `198.51.100.13` | Master Node | 16 GB RAM - 60+ GB HDD - 4 CPU |

> The addresses above are documentation placeholders only.

## Installation Flow

1. Configure the Bastion node.
2. Configure DNS.
3. Configure NTP/Chrony.
4. Configure HAProxy.
5. Install and configure the mirror registry.
6. Configure and trust the custom CA.
7. Install `oc`, `kubectl`, `openshift-install`, and `oc-mirror`.
8. Mirror the OpenShift release with `oc-mirror` v2.
9. Prepare `ImageSetConfiguration`.
10. Prepare `ImageDigestMirrorSet` and `ImageTagMirrorSet`.
11. Prepare ABI `agent-config.yaml`.
12. Prepare `install-config.yaml`.
13. Generate the Agent ISO.
14. Boot the three master nodes from the Agent ISO.
15. Monitor bootstrap and cluster installation.
16. Validate the cluster.

## Security

Do not commit:

- Pull secrets
- SSH private keys
- Registry passwords
- TLS private keys
- Real certificates
- Kubeconfigs
- `kubeadmin-password`
- Generated ISO files
- Real ignition files

All examples in this repository use placeholders.
