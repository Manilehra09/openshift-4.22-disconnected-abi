# DNS Troubleshooting

From a master:

```bash
cat /etc/resolv.conf
getent hosts api.ocp.example.com
getent hosts api-int.ocp.example.com
getent hosts master1.example.com
```

From Bastion:

```bash
dig @<BASTION_IP> api.ocp.example.com
dig @<BASTION_IP> master1.example.com
dig @<BASTION_IP> -x <MASTER1_IP>
```

Check BIND:

```bash
systemctl status named
named-checkconf
named-checkzone example.com /var/named/forward
```
