# Install Mirror Registry

The disconnected OpenShift cluster obtains release images from the mirror registry.

Example registry:

```text
registry.example.com:8443
198.51.100.20
```

## Install Required Packages

On the registry host:

```bash
dnf install -y podman
podman version
```

## Prepare Storage

Check available space:

```bash
df -h
```

The registry requires sufficient space for the OpenShift release images and future content.

## Mirror Registry

Copy the Red Hat mirror-registry archive to the registry host.

Example:

```bash
tar -tzf mirror-registry-amd64.tar.gz
```

Check the tool:

```bash
./mirror-registry --version
```

Install using the appropriate mirror-registry command for your environment.

After installation check:

```bash
podman ps
ss -lntp | grep 8443
curl -k https://registry.example.com:8443/v2/
```

The registry should return a successful response from `/v2/`.
