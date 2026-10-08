# Mirror Registry Troubleshooting

Check containers:

```bash
podman ps -a
```

Check port:

```bash
ss -lntp | grep 8443
```

Check registry API:

```bash
curl -k https://registry.example.com:8443/v2/
```

Check storage:

```bash
df -h
```

Check certificate:

```bash
openssl s_client \
  -connect registry.example.com:8443 \
  -servername registry.example.com
```

Verify that the CA used to sign the registry certificate is trusted by the Bastion and by the installation environment.
