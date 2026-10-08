# Troubleshooting

Use the troubleshooting documents when installation does not progress.

Start with:

```bash
systemctl --failed
sudo crictl ps -a
free -h
df -h
```

Then check:

- DNS
- NTP
- HAProxy
- registry connectivity
- API server
- etcd
- memory/OOM events
- disk space
