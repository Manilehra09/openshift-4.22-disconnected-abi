# Configure NTP / Chrony

All OpenShift nodes must have consistent time.

## Configure Chrony on Bastion

```bash
dnf install -y chrony
vim /etc/chrony.conf
```

Add the cluster network:

```conf
allow 198.51.100.0/24
```

Configure an Internet time source, for example:

```conf
pool 2.rhel.pool.ntp.org iburst
```

Start Chrony:

```bash
systemctl enable --now chronyd
```

Check:

```bash
chronyc tracking
chronyc sources -v
ss -lunp | grep ':123'
```

## Test From a Master

After the master has network connectivity:

```bash
chronyc sources -v
chronyc tracking
```

The master nodes should use the Bastion as their internal NTP server.
