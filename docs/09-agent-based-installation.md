# Agent-Based Installation

This lab uses the OpenShift Agent-Based Installer.

The cluster contains three control-plane nodes and no workers.

## Create Working Directory

```bash
mkdir -p /root/ocp-4.22/abi-ocp-4.22.15
cd /root/ocp-4.22/abi-ocp-4.22.15
```

## Create install-config.yaml

```bash
vim install-config.yaml
```

Example:

```yaml
apiVersion: v1
baseDomain: example.com

metadata:
  name: ocp

compute:
  - name: worker
    replicas: 0

controlPlane:
  name: master
  replicas: 3

networking:
  clusterNetwork:
    - cidr: 10.128.0.0/14
      hostPrefix: 23
  networkType: OVNKubernetes
  serviceNetwork:
    - 172.30.0.0/16

platform:
  none: {}

fips: false

pullSecret: '{"auths": ...}'
sshKey: "ssh-ed25519 AAAA..."
```

Replace:

- `baseDomain`
- cluster name
- pull secret
- SSH public key

with values from your environment.

## Create Agent Config

```bash
vim agent-config.yaml
```

Example structure:

```yaml
apiVersion: v1alpha1
kind: AgentConfig

metadata:
  name: ocp

rendezvousIP: 198.51.100.11

additionalNTPSources:
  - 198.51.100.10

hosts:
  - hostname: master1.example.com
    role: master
    interfaces:
      - name: ens160
        macAddress: "00:00:00:00:00:11"
    networkConfig:
      interfaces:
        - name: ens160
          type: ethernet
          state: up
          ipv4:
            enabled: true
            address:
              - ip: 198.51.100.11
                prefix-length: 24
          ipv6:
            enabled: false
      dns-resolver:
        config:
          server:
            - 198.51.100.10
      routes:
        config:
          - destination: 0.0.0.0/0
            next-hop-address: 198.51.100.10
            next-hop-interface: ens160

  - hostname: master2.example.com
    role: master
    interfaces:
      - name: ens160
        macAddress: "00:00:00:00:00:12"

  - hostname: master3.example.com
    role: master
    interfaces:
      - name: ens160
        macAddress: "00:00:00:00:00:13"
```

> The exact host network sections must match the NIC names, MAC addresses and network used by your VMware or physical lab.

## Add Mirror Configuration

Use the generated `ImageDigestMirrorSet` / image digest mirror configuration from `oc-mirror`.

Do not manually invent the generated mirror mappings. Copy the generated sanitized content into the documentation after successful mirroring.

## Generate Agent ISO

From the OpenShift installer directory:

```bash
openshift-install agent create image \
  --dir=/root/ocp-4.22/abi-ocp-4.22.15
```

Expected output is similar to:

```text
INFO Configuration has 3 master replicas, 0 arbiter replicas, and 0 worker replicas
INFO The rendezvous host IP (node0 IP) is 198.51.100.11
INFO Extracting base ISO from release payload
INFO Consuming Agent Config from target directory
INFO Consuming Install Config from target directory
INFO Generated ISO at /root/ocp-4.22/abi-ocp-4.22.15/agent.x86_64.iso.
```

Check:

```bash
ls -lh /root/ocp-4.22/abi-ocp-4.22.15/agent.x86_64.iso
```

## Boot the Master Nodes

Attach the Agent ISO to:

```text
master1
master2
master3
```

Power on the machines.

The Agent installer discovers the hosts and starts the installation automatically.

## Monitor Installation

From the Bastion:

```bash
openshift-install agent wait-for bootstrap-complete \
  --dir=/root/ocp-4.22/abi-ocp-4.22.15 \
  --log-level=info
```

After bootstrap:

```bash
openshift-install agent wait-for install-complete \
  --dir=/root/ocp-4.22/abi-ocp-4.22.15 \
  --log-level=info
```
