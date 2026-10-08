# HAProxy Troubleshooting

Check configuration:

```bash
haproxy -c -f /etc/haproxy/haproxy.cfg
```

Check service:

```bash
systemctl status haproxy
journalctl -u haproxy --since "30 minutes ago"
```

Check ports:

```bash
ss -lntp | grep -E ':(80|443|6443|22623|9000)'
```

Test master ports:

```bash
nc -zv <MASTER1_IP> 6443
nc -zv <MASTER2_IP> 6443
nc -zv <MASTER3_IP> 6443
```
