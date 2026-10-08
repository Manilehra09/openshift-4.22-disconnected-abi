# Troubleshooting

## Check Agent Installation

```bash
openshift-install agent wait-for bootstrap-complete \
  --dir=/root/ocp-4.22/abi-ocp-4.22.15 \
  --log-level=info
```

## SSH to the Rendezvous Host

The first master is normally the rendezvous host in this lab.

```bash
ssh core@master1.example.com
```

Check services:

```bash
systemctl --failed
systemctl status release-image.service
systemctl status bootkube.service
systemctl status node-image-pull.service
```

## Check Containers

```bash
sudo crictl ps -a
```

Search for API server containers:

```bash
sudo crictl ps -a | grep -Ei 'kube-apiserver|openshift-apiserver|oauth-apiserver'
```

## Check API Server Logs

Find the container ID:

```bash
sudo crictl ps -a | grep kube-apiserver
```

Then:

```bash
sudo crictl logs <CONTAINER_ID>
```

Look for:

```text
poststarthook
readyz
RBAC
etcd
connection refused
timeout
```

## Check etcd

```bash
sudo crictl ps -a | grep etcd
sudo journalctl -u etcd --no-pager
```

If etcd is repeatedly restarting, check memory and disk immediately.

## Check Memory

On every master:

```bash
free -h
grep MemTotal /proc/meminfo
sudo ps aux --sort=-%mem | head -20
sudo crictl stats
```

Check kernel OOM events:

```bash
sudo journalctl -k --since "1 hour ago" | \
  grep -Ei "out of memory|oom|killed process"
```

An OOM event involving `etcd`, `crio`, `kube-apiserver`, or other core services can cause secondary API and bootstrap failures.

## Check Disk

```bash
df -h
df -ih
```

## Check HAProxy Backends

On Bastion:

```bash
journalctl -u haproxy --since "30 minutes ago"
```

Check API connectivity:

```bash
nc -zv master1.example.com 6443
nc -zv master2.example.com 6443
nc -zv master3.example.com 6443
```

Check Machine Config Server:

```bash
nc -zv master1.example.com 22623
```

## Check DNS From Bastion

```bash
dig master1.example.com
dig api.ocp.example.com
dig api-int.ocp.example.com
```

## Check Registry

```bash
curl -k https://registry.example.com:8443/v2/
```

On registry:

```bash
podman ps
ss -lntp | grep 8443
```
