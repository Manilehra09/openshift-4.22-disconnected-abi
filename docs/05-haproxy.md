# Configure HAProxy

HAProxy provides the load-balancing endpoints required by the cluster.

## Install HAProxy

```bash
dnf install -y haproxy
```

## Configure HAProxy

```bash
vim /etc/haproxy/haproxy.cfg
```

Example:

```conf
global
    maxconn 20000
    log /dev/log local0 info
    chroot /var/lib/haproxy
    pidfile /var/run/haproxy.pid
    user haproxy
    group haproxy
    daemon
    stats socket /var/lib/haproxy/stats

defaults
    log global
    mode http
    option httplog
    option dontlognull
    option http-server-close
    option redispatch
    option forwardfor except 127.0.0.0/8
    retries 3
    maxconn 20000
    timeout http-request 10000ms
    timeout http-keep-alive 10000ms
    timeout check 10000ms
    timeout connect 40000ms
    timeout client 300000ms
    timeout server 300000ms
    timeout queue 50000ms

listen stats
    bind :9000
    stats uri /stats
    stats refresh 10000ms

frontend k8s_api_frontend
    bind :6443
    default_backend k8s_api_backend
    mode tcp

backend k8s_api_backend
    mode tcp
    balance source
    server master1 198.51.100.11:6443 check
    server master2 198.51.100.12:6443 check
    server master3 198.51.100.13:6443 check

frontend ocp_machine_config_server_frontend
    mode tcp
    bind :22623
    default_backend ocp_machine_config_server_backend

backend ocp_machine_config_server_backend
    mode tcp
    balance source
    server master1 198.51.100.11:22623 check
    server master2 198.51.100.12:22623 check
    server master3 198.51.100.13:22623 check

frontend ocp_http_ingress_frontend
    bind :80
    default_backend ocp_http_ingress_backend
    mode tcp

backend ocp_http_ingress_backend
    mode tcp
    balance source
    server master1 198.51.100.11:80 check
    server master2 198.51.100.12:80 check
    server master3 198.51.100.13:80 check

frontend ocp_https_ingress_frontend
    bind *:443
    default_backend ocp_https_ingress_backend
    mode tcp

backend ocp_https_ingress_backend
    mode tcp
    balance source
    server master1 198.51.100.11:443 check
    server master2 198.51.100.12:443 check
    server master3 198.51.100.13:443 check
```

Validate:

```bash
haproxy -c -f /etc/haproxy/haproxy.cfg
```

Enable SELinux connectivity:

```bash
setsebool -P haproxy_connect_any on
```

Start:

```bash
systemctl enable --now haproxy
```

Check listeners:

```bash
ss -lntp | grep -E ':(80|443|6443|22623|9000)'
```
