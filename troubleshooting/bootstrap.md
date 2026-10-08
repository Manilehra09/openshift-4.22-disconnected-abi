# Bootstrap Troubleshooting

Run:

```bash
openshift-install agent wait-for bootstrap-complete \
  --dir=/root/ocp-4.22/abi-ocp-4.22.15 \
  --log-level=info
```

On the rendezvous host:

```bash
systemctl --failed
systemctl status bootkube.service
systemctl status release-image.service
systemctl status node-image-pull.service
```

Check:

```bash
sudo crictl ps -a
sudo journalctl -u bootkube.service --no-pager
```

If bootstrap reports repeated API connection failures, check:

1. API server.
2. etcd.
3. Memory/OOM.
4. DNS.
5. NTP.
6. HAProxy.
7. Registry access.
