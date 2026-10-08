# Memory / OOM Troubleshooting

If core OpenShift services are killed by the Linux kernel, bootstrap can fail even when DNS, HAProxy and the Agent installation initially look correct.

## Check Memory

```bash
free -h
grep MemTotal /proc/meminfo
sudo ps aux --sort=-%mem | head -20
sudo crictl stats
```

## Check OOM Events

```bash
sudo journalctl -k --since "1 hour ago" | \
  grep -Ei "out of memory|oom|killed process"
```

Pay particular attention to kills involving:

```text
etcd
crio
kube-apiserver
NetworkManager
```

## Check All Masters

Run the same commands on all three masters.

If a VM has insufficient memory, correct the VM allocation and reboot the affected node before continuing bootstrap troubleshooting.
