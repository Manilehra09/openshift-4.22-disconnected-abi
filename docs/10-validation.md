# Validate the Installation

## Validate DNS

```bash
dig @<BASTION_IP> api.ocp.example.com
dig @<BASTION_IP> api-int.ocp.example.com
dig @<BASTION_IP> master1.example.com
```

## Validate NTP

On each master:

```bash
chronyc tracking
chronyc sources -v
```

## Validate HAProxy

On Bastion:

```bash
haproxy -c -f /etc/haproxy/haproxy.cfg
systemctl status haproxy
ss -lntp | grep -E ':(80|443|6443|22623)'
```

## Validate Registry

```bash
curl -k https://registry.example.com:8443/v2/
```

## Validate OpenShift

```bash
export KUBECONFIG=/root/ocp-4.22/abi-ocp-4.22.15/auth/kubeconfig

oc get nodes
oc get clusterversion
oc get clusteroperators
```

All master nodes should eventually report `Ready`.

Check:

```bash
oc get nodes -o wide
```

## Check Cluster Operators

```bash
oc get clusteroperators
```

Wait until the operators report healthy conditions.

## Check API

```bash
oc whoami
oc get clusterversion
```
