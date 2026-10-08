# API Server Troubleshooting

Check whether the API server is listening:

```bash
sudo ss -lntp | grep 6443
```

Check containers:

```bash
sudo crictl ps -a | grep -Ei 'kube-apiserver|openshift-apiserver|oauth-apiserver'
```

Get logs:

```bash
sudo crictl logs <CONTAINER_ID>
```

Look for:

```text
poststarthook
readyz
RBAC
etcd
timeout
connection refused
```

If the Kubernetes API server is not ready, HAProxy may show all API backends as DOWN. Fix the master-side API problem before changing HAProxy.

Check etcd:

```bash
sudo crictl ps -a | grep etcd
sudo journalctl -u etcd --no-pager
```
