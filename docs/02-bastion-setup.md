# Configure Bastion Node

First configure the Bastion node with DNS, Chrony/NTP and HAProxy services.

## Install Required Packages

```bash
dnf install -y bind bind-utils chrony haproxy podman
```

Enable the services:

```bash
systemctl enable --now named
systemctl enable --now chronyd
systemctl enable --now haproxy
```

Check the services:

```bash
systemctl status named
systemctl status chronyd
systemctl status haproxy
```

## Check Network

```bash
ip addr
ip route
```

The Bastion should have:

- An Internet-facing interface for downloading OpenShift content.
- A cluster-facing interface for DNS, NTP, HAProxy and cluster traffic.

Do not configure a second default route on the cluster-facing interface.

Example:

```bash
nmcli connection modify <cluster-connection> ipv4.never-default yes
nmcli connection down <cluster-connection>
nmcli connection up <cluster-connection>
```

Verify the Internet route:

```bash
ip route get 1.1.1.1
```
