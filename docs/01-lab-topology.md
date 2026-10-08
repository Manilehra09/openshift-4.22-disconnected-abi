# Lab Topology

In the lab installation I am using the following machines with their respective IP addresses.

| Hostname | IP address | Description | Hardware Requirement |
| :--- | :--- | :--- | :--- |
| `bastion.example.com` | `192.0.2.10` | Bastion / Helper Node | 16 GB RAM - 60 GB HDD - 4 CPU |
| `registry.example.com` | `192.0.2.20` | Mirror Registry | 6+ GB RAM - 100+ GB storage |
| `master1.example.com` | `198.51.100.11` | Master Node | 16 GB RAM - 60+ GB HDD - 4 CPU |
| `master2.example.com` | `198.51.100.12` | Master Node | 16 GB RAM - 60+ GB HDD - 4 CPU |
| `master3.example.com` | `198.51.100.13` | Master Node | 16 GB RAM - 60+ GB HDD - 4 CPU |

## Network

Example cluster network:

```text
Bastion
  |
  +---- Registry
  |
  +---- Master1
  |
  +---- Master2
  |
  +---- Master3
```

The Bastion provides DNS, NTP and HAProxy services.

The registry is reachable from the cluster network but does not require Internet access from the master nodes.

## Hostname Resolution

The following records are required:

```text
bastion.example.com       -> 192.0.2.10
registry.example.com      -> 192.0.2.20

api.ocp.example.com       -> 192.0.2.10
api-int.ocp.example.com   -> 192.0.2.10
*.apps.ocp.example.com    -> 192.0.2.10

master1.example.com       -> 198.51.100.11
master2.example.com       -> 198.51.100.12
master3.example.com       -> 198.51.100.13
```
