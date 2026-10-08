# Configure DNS on Bastion Node

Configure DNS on the Bastion node before creating the Agent ISO.

## Install DNS

```bash
dnf install -y bind bind-utils
```

## Configure named.conf

```bash
vim /etc/named.conf
```

Example:

```conf
options {
    listen-on port 53 { 127.0.0.1; 198.51.100.10; };
    listen-on-v6 port 53 { ::1; };

    allow-query { localhost; 198.51.100.0/24; };

    recursion yes;
    allow-recursion { localhost; 198.51.100.0/24; };

    dnssec-validation yes;
};

zone "example.com" IN {
    type master;
    file "forward";
};

zone "100.51.198.in-addr.arpa" IN {
    type master;
    file "reverse";
};
```

## Create the Forward Zone

```bash
vim /var/named/forward
```

```dns
$TTL 1D
@ IN SOA bastion.example.com. admin.example.com. (
    2026100801
    1D
    1H
    1W
    3H
)

@       IN NS bastion.example.com.

bastion  IN A 192.0.2.10
registry IN A 192.0.2.20

master1  IN A 198.51.100.11
master2  IN A 198.51.100.12
master3  IN A 198.51.100.13

api.ocp      IN A 192.0.2.10
api-int.ocp  IN A 192.0.2.10
*.apps.ocp   IN A 192.0.2.10
```

## Create the Reverse Zone

```bash
vim /var/named/reverse
```

```dns
$TTL 1D
@ IN SOA bastion.example.com. admin.example.com. (
    2026100801
    1D
    1H
    1W
    3H
)

@ IN NS bastion.example.com.

10 IN PTR bastion.example.com.
20 IN PTR registry.example.com.

11 IN PTR master1.example.com.
12 IN PTR master2.example.com.
13 IN PTR master3.example.com.
```

Change ownership:

```bash
chgrp named /var/named/forward
chgrp named /var/named/reverse
```

Validate the zone:

```bash
named-checkzone example.com /var/named/forward
named-checkzone 100.51.198.in-addr.arpa /var/named/reverse
named-checkconf
```

Start DNS:

```bash
systemctl enable --now named
```

Test:

```bash
dig @198.51.100.10 master1.example.com
dig @198.51.100.10 api.ocp.example.com
dig @198.51.100.10 -x 198.51.100.11
```
