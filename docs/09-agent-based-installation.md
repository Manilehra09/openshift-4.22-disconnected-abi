# Install OpenShift 4.22 Using Agent-Based Installer

In this lab installation I am using the OpenShift Agent-Based Installer (ABI) to install OpenShift Container Platform 4.22 in a disconnected environment.

The cluster contains three control-plane nodes and no worker nodes.

The OpenShift release images are mirrored to a private mirror registry using `oc-mirror` v2.

---

## Lab Installation Topology

The following machines are used for the OpenShift installation.

| Hostname | IP Address | Description | Hardware Requirement |
| :--- | :--- | :--- | :--- |
| `bastion.example.com` | `<BASTION_IP>` | Bastion / Helper Node | 16 GB RAM - 60 GB HDD - 4 CPU |
| `registry.example.com` | `<REGISTRY_IP>` | Mirror Registry | 6+ GB RAM - 100+ GB Storage |
| `master1.example.com` | `<MASTER1_IP>` | Master Node | 16 GB RAM - 60+ GB HDD - 4 CPU |
| `master2.example.com` | `<MASTER2_IP>` | Master Node | 16 GB RAM - 60+ GB HDD - 4 CPU |
| `master3.example.com` | `<MASTER3_IP>` | Master Node | 16 GB RAM - 60+ GB HDD - 4 CPU |

The actual IP addresses, MAC addresses and credentials should be replaced according to your lab environment.

---

## 1. Verify OpenShift Tools

Before starting the Agent-Based installation, verify that the required OpenShift commands are available on the Bastion node.

Check `oc`:

```bash
oc version
```

Check `kubectl`:

```bash
kubectl version --client
```

Check `openshift-install`:

```bash
openshift-install version
```

Check `oc-mirror`:

```bash
oc-mirror version
```

For this lab, the OpenShift release being installed is:

```text
OpenShift Container Platform 4.22.15
```

The installer, `oc`, and `oc-mirror` versions should be compatible with the OpenShift release being installed.

---

## 2. Verify DNS

Before creating the Agent ISO, verify that DNS is working correctly.

From the Bastion node:

```bash
dig master1.example.com
dig master2.example.com
dig master3.example.com
```

Verify the API records:

```bash
dig api.ocp.example.com
dig api-int.ocp.example.com
```

Verify reverse DNS:

```bash
dig -x <MASTER1_IP>
dig -x <MASTER2_IP>
dig -x <MASTER3_IP>
```

The master nodes must be able to resolve the required cluster hostnames.

---

## 3. Verify NTP

OpenShift nodes require synchronized time.

On the Bastion:

```bash
chronyc tracking
```

Check the configured NTP sources:

```bash
chronyc sources -v
```

Check that Chrony is listening:

```bash
ss -lunp | grep ':123'
```

The master nodes should use the Bastion as their internal NTP server.

---

## 4. Verify Mirror Registry

The OpenShift release images must already be available in the disconnected mirror registry.

Example registry:

```text
registry.example.com:8443
```

Test the registry:

```bash
curl -k https://registry.example.com:8443/v2/
```

The command should return a successful response.

Check the registry from the Bastion:

```bash
podman login registry.example.com:8443
```

Use the registry credentials configured for your environment.

Do not place the registry password in Git.

---

## 5. Verify OpenShift Release Was Mirrored

The OpenShift release should already have been mirrored using `oc-mirror` v2.

Example `ImageSetConfiguration`:

```yaml
apiVersion: mirror.openshift.io/v2alpha1
kind: ImageSetConfiguration
mirror:
  platform:
    channels:
      - name: stable-4.22
        minVersion: 4.22.15
        maxVersion: 4.22.15
        type: ocp
    graph: true
```

The mirror command is similar to:

```bash
oc-mirror \
  -c /root/ocp-4.22/isc-ocp-4.22.15.yaml \
  --workspace file:///root/ocp-4.22/oc-mirror-workspace \
  --authfile /root/ocp-4.22/pull-secret-mirror.json \
  docker://registry.example.com:8443 \
  --v2
```

After the mirror operation completes, verify the generated files:

```bash
find /root/ocp-4.22/oc-mirror-workspace \
  -type f | sort
```

The generated mirror configuration should be used during the Agent-Based installation.

---

## 6. Create the ABI Working Directory

Create a directory for the OpenShift Agent-Based installation.

```bash
mkdir -p /root/ocp-4.22/abi-ocp-4.22.15
```

Change to the directory:

```bash
cd /root/ocp-4.22/abi-ocp-4.22.15
```

Verify:

```bash
pwd
```

Expected:

```text
/root/ocp-4.22/abi-ocp-4.22.15
```

---

## 7. Create `install-config.yaml`

Create the OpenShift installation configuration file.

```bash
vim /root/ocp-4.22/abi-ocp-4.22.15/install-config.yaml
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

pullSecret: '<PULL_SECRET>'

sshKey: '<SSH_PUBLIC_KEY>'
```

Replace the following values with the values from your environment:

```text
example.com
ocp
<PULL_SECRET>
<SSH_PUBLIC_KEY>
```

---

## 8. Verify `install-config.yaml`

Check the file:

```bash
cat /root/ocp-4.22/abi-ocp-4.22.15/install-config.yaml
```

Verify:

```text
baseDomain
cluster name
controlPlane replicas
compute replicas
clusterNetwork
serviceNetwork
networkType
pullSecret
sshKey
```

For this lab:

```text
Control Plane: 3
Workers:       0
Network Type:  OVNKubernetes
```

---

## 9. Create `agent-config.yaml`

The Agent configuration defines the hosts that will participate in the installation.

Create the file:

```bash
vim /root/ocp-4.22/abi-ocp-4.22.15/agent-config.yaml
```

Example:

```yaml
apiVersion: v1alpha1
kind: AgentConfig

metadata:
  name: ocp

rendezvousIP: <MASTER1_IP>

additionalNTPSources:
  - <BASTION_CLUSTER_IP>

hosts:

  - hostname: master1.example.com

    role: master

    interfaces:
      - name: <NIC_NAME>
        macAddress: "<MASTER1_MAC>"

    networkConfig:
      interfaces:

        - name: <NIC_NAME>
          type: ethernet
          state: up

          ipv4:
            enabled: true

            address:
              - ip: <MASTER1_IP>
                prefix-length: 24

          ipv6:
            enabled: false

      dns-resolver:
        config:
          server:
            - <BASTION_CLUSTER_IP>

      routes:
        config:

          - destination: 0.0.0.0/0
            next-hop-address: <BASTION_CLUSTER_IP>
            next-hop-interface: <NIC_NAME>


  - hostname: master2.example.com

    role: master

    interfaces:
      - name: <NIC_NAME>
        macAddress: "<MASTER2_MAC>"

    networkConfig:
      interfaces:

        - name: <NIC_NAME>
          type: ethernet
          state: up

          ipv4:
            enabled: true

            address:
              - ip: <MASTER2_IP>
                prefix-length: 24

          ipv6:
            enabled: false

      dns-resolver:
        config:
          server:
            - <BASTION_CLUSTER_IP>

      routes:
        config:

          - destination: 0.0.0.0/0
            next-hop-address: <BASTION_CLUSTER_IP>
            next-hop-interface: <NIC_NAME>


  - hostname: master3.example.com

    role: master

    interfaces:
      - name: <NIC_NAME>
        macAddress: "<MASTER3_MAC>"

    networkConfig:
      interfaces:

        - name: <NIC_NAME>
          type: ethernet
          state: up

          ipv4:
            enabled: true

            address:
              - ip: <MASTER3_IP>
                prefix-length: 24

          ipv6:
            enabled: false

      dns-resolver:
        config:
          server:
            - <BASTION_CLUSTER_IP>

      routes:
        config:

          - destination: 0.0.0.0/0
            next-hop-address: <BASTION_CLUSTER_IP>
            next-hop-interface: <NIC_NAME>
```

---

## 10. Agent Configuration Parameters

The important values in `agent-config.yaml` are described below.

### Rendezvous IP

```yaml
rendezvousIP: <MASTER1_IP>
```

The rendezvous IP is the IP address of the node that initially coordinates the Agent installation.

In this three-master lab, `master1` is used as the rendezvous host.

### NTP

```yaml
additionalNTPSources:
  - <BASTION_CLUSTER_IP>
```

The Bastion provides the internal NTP service.

### Hostnames

```yaml
hostname: master1.example.com
hostname: master2.example.com
hostname: master3.example.com
```

These names must match the DNS configuration.

### MAC Addresses

Each host must have the correct MAC address:

```yaml
macAddress: "<MASTER1_MAC>"
```

```yaml
macAddress: "<MASTER2_MAC>"
```

```yaml
macAddress: "<MASTER3_MAC>"
```

The MAC address should be taken from the actual VMware or physical interface.

For example:

```bash
ip link
```

or:

```bash
nmcli device show
```

---

## 11. Verify the Network Interface Name

Before finalizing `agent-config.yaml`, verify the interface name on each master.

For example:

```bash
ip link
```

or:

```bash
nmcli device
```

The interface might be:

```text
ens160
```

or another name depending on the virtual machine configuration.

Use the actual interface name in `agent-config.yaml`.

Example:

```yaml
interfaces:
  - name: ens160
    macAddress: "<MASTER1_MAC>"
```

Do not assume that every environment uses `ens160`.

---

## 12. Add Image Mirror Configuration

The OpenShift installation must use the disconnected mirror registry instead of attempting to pull release images directly from the Internet.

The `oc-mirror` operation generates the required mirror configuration.

The generated configuration can contain an `ImageDigestMirrorSet`.

Example:

```yaml
apiVersion: config.openshift.io/v1
kind: ImageDigestMirrorSet

metadata:
  name: idms-release-0

spec:
  imageDigestMirrors:

    - mirrors:
        - registry.example.com:8443/openshift/release

      source: quay.io/openshift-release-dev/ocp-v4.0-art-dev

    - mirrors:
        - registry.example.com:8443/openshift/release-images

      source: quay.io/openshift-release-dev/ocp-release
```

The exact generated content should come from the `oc-mirror` workspace.

Do not manually change generated mirror mappings unless you understand the consequences.

---

## 13. Verify the Installation Files

Before generating the Agent ISO, verify that the required files exist.

```bash
cd /root/ocp-4.22/abi-ocp-4.22.15
```

Run:

```bash
ls -lh
```

You should have at least:

```text
install-config.yaml
agent-config.yaml
```

The required mirror configuration must also be available according to the OpenShift release and `oc-mirror` output being used.

---

## 14. Verify Pull Secret

The pull secret is required to obtain the OpenShift release payload.

Check the installation configuration:

```bash
grep -E 'pullSecret|sshKey' install-config.yaml
```

Do not display or paste the real pull secret into a public GitHub issue, README or repository.

For documentation, use:

```yaml
pullSecret: '<PULL_SECRET>'
```

---

## 15. Verify SSH Public Key

The SSH public key is used for access to the OpenShift nodes.

Check your public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

or:

```bash
cat ~/.ssh/id_rsa.pub
```

Copy only the public key into:

```yaml
sshKey: '<SSH_PUBLIC_KEY>'
```

Never put the private key in `install-config.yaml`.

---

## 16. Generate Agent ISO

Once `install-config.yaml` and `agent-config.yaml` are ready, generate the Agent-Based Installer ISO.

Change to the installation directory:

```bash
cd /root/ocp-4.22/abi-ocp-4.22.15
```

Run:

```bash
openshift-install agent create image \
  --dir=/root/ocp-4.22/abi-ocp-4.22.15
```

The installer will process the configuration files and create the Agent ISO.

Expected output is similar to:

```text
INFO Configuration has 3 master replicas, 0 arbiter replicas, and 0 worker replicas
INFO The rendezvous host IP (node0 IP) is <MASTER1_IP>
INFO Extracting base ISO from release payload
INFO Consuming Agent Config from target directory
INFO Consuming Install Config from target directory
INFO Generated ISO at /root/ocp-4.22/abi-ocp-4.22.15/agent.x86_64.iso.
```

---

## 17. Verify the Generated ISO

Check the ISO:

```bash
ls -lh /root/ocp-4.22/abi-ocp-4.22.15/agent.x86_64.iso
```

The ISO should be available as:

```text
/root/ocp-4.22/abi-ocp-4.22.15/agent.x86_64.iso
```

The ISO is now ready to be attached to the master virtual machines.

Do not commit the ISO to GitHub.

---

## 18. Copy the Agent ISO to the Hypervisor

Copy the ISO to the machine from which you manage the VMware virtual machines.

For example, using `scp`:

```bash
scp /root/ocp-4.22/abi-ocp-4.22.15/agent.x86_64.iso \
    <USER>@<MANAGEMENT_HOST>:/<PATH>/
```

Alternatively, download or copy the file using your preferred secure method.

---

## 19. Attach ISO to Master Nodes

Attach the generated:

```text
agent.x86_64.iso
```

to:

```text
master1
master2
master3
```

The three virtual machines should use the same network segment as the OpenShift cluster network.

Verify that each VM has:

- Correct CPU
- Correct memory
- Correct disk
- Correct network adapter
- Correct MAC address
- Agent ISO attached

---

## 20. Start the Master Nodes

Power on:

```text
master1
master2
master3
```

The Agent ISO will boot the systems.

The Agent installer will discover the hosts based on the configuration supplied in `agent-config.yaml`.

---

## 21. Verify the Hosts From the Bastion

Check DNS:

```bash
ping master1.example.com
ping master2.example.com
ping master3.example.com
```

Check connectivity:

```bash
nc -zv <MASTER1_IP> 6443
nc -zv <MASTER2_IP> 6443
nc -zv <MASTER3_IP> 6443
```

Check Machine Config Server:

```bash
nc -zv <MASTER1_IP> 22623
nc -zv <MASTER2_IP> 22623
nc -zv <MASTER3_IP> 22623
```

During early installation, some ports may not be available yet.

Continue monitoring the installation.

---

## 22. Monitor Agent Installation

From the Bastion node, run:

```bash
openshift-install agent wait-for bootstrap-complete \
  --dir=/root/ocp-4.22/abi-ocp-4.22.15 \
  --log-level=info
```

The installer will monitor the bootstrap process.

The output provides information about:

- Host validation
- DNS validation
- NTP validation
- Host readiness
- Installation progress
- Bootstrap completion

---

## 23. Monitor the Rendezvous Host

The rendezvous host is the first master defined by:

```yaml
rendezvousIP: <MASTER1_IP>
```

SSH to the node:

```bash
ssh core@master1.example.com
```

Check failed services:

```bash
systemctl --failed
```

Check the release image service:

```bash
systemctl status release-image.service
```

Check bootkube:

```bash
systemctl status bootkube.service
```

Check node image pull:

```bash
systemctl status node-image-pull.service
```

---

## 24. Check Containers During Bootstrap

On the rendezvous host:

```bash
sudo crictl ps -a
```

Check the Kubernetes API server:

```bash
sudo crictl ps -a | grep kube-apiserver
```

Check etcd:

```bash
sudo crictl ps -a | grep etcd
```

Check all OpenShift-related containers:

```bash
sudo crictl ps -a | grep -Ei 'openshift|kube|etcd'
```

---

## 25. Check API Server

Check whether port 6443 is listening:

```bash
sudo ss -lntp | grep 6443
```

If the API server container is running, obtain its container ID:

```bash
sudo crictl ps -a | grep kube-apiserver
```

Then check its logs:

```bash
sudo crictl logs <CONTAINER_ID>
```

Look for errors involving:

```text
readyz
poststarthook
RBAC
etcd
connection refused
timeout
```

---

## 26. Check etcd

Check etcd containers:

```bash
sudo crictl ps -a | grep etcd
```

Check etcd logs:

```bash
sudo crictl logs <ETCD_CONTAINER_ID>
```

Check the system journal:

```bash
sudo journalctl --no-pager | grep etcd
```

etcd is a critical component of the OpenShift control plane.

If etcd repeatedly stops or is killed, check system memory immediately.

---

## 27. Check Memory During Bootstrap

Each master should have sufficient memory for the control-plane installation.

Check:

```bash
free -h
```

Check total memory:

```bash
grep MemTotal /proc/meminfo
```

Check the largest processes:

```bash
sudo ps aux --sort=-%mem | head -20
```

Check container resource usage:

```bash
sudo crictl stats
```

Check kernel OOM events:

```bash
sudo journalctl -k --since "1 hour ago" | \
  grep -Ei "out of memory|oom|killed process"
```

If the kernel kills processes such as:

```text
etcd
crio
kube-apiserver
NetworkManager
```

the cluster can fail to bootstrap.

---

## 28. Check Disk Space

Check disk space:

```bash
df -h
```

Check inode usage:

```bash
df -ih
```

The nodes must have sufficient free disk space for:

- Container images
- etcd data
- OpenShift payload
- Logs
- Temporary installation data

---

## 29. Wait for Bootstrap Completion

From the Bastion:

```bash
openshift-install agent wait-for bootstrap-complete \
  --dir=/root/ocp-4.22/abi-ocp-4.22.15 \
  --log-level=info
```

Wait until the installer reports that bootstrap has completed successfully.

Do not reboot or destroy the master nodes while the installation is still progressing unless troubleshooting requires it.

---

## 30. Wait for Installation Completion

After bootstrap has completed, run:

```bash
openshift-install agent wait-for install-complete \
  --dir=/root/ocp-4.22/abi-ocp-4.22.15 \
  --log-level=info
```

The installer will wait for the OpenShift installation to complete.

---

## 31. Configure KUBECONFIG

After installation is complete, configure the OpenShift client.

```bash
export KUBECONFIG=/root/ocp-4.22/abi-ocp-4.22.15/auth/kubeconfig
```

Verify:

```bash
echo $KUBECONFIG
```

Expected:

```text
/root/ocp-4.22/abi-ocp-4.22.15/auth/kubeconfig
```

---

## 32. Verify OpenShift Access

Check the current user:

```bash
oc whoami
```

Check the cluster version:

```bash
oc version
```

Check the OpenShift release:

```bash
oc get clusterversion
```

---

## 33. Check Master Nodes

Run:

```bash
oc get nodes
```

Expected result:

```text
NAME      STATUS   ROLES                  AGE   VERSION
master1   Ready    control-plane,master   ...   ...
master2   Ready    control-plane,master   ...   ...
master3   Ready    control-plane,master   ...   ...
```

Check detailed information:

```bash
oc get nodes -o wide
```

---

## 34. Check Cluster Operators

Run:

```bash
oc get clusteroperators
```

or:

```bash
oc get co
```

The Cluster Operators should eventually report healthy conditions.

Check the detailed status:

```bash
oc get clusteroperators -o wide
```

---

## 35. Check Cluster Version

Run:

```bash
oc get clusterversion
```

For detailed output:

```bash
oc get clusterversion -o yaml
```

Verify that the expected OpenShift release is installed.

---

## 36. Check Pods

Check all namespaces:

```bash
oc get pods -A
```

Check the Kubernetes API server namespace:

```bash
oc get pods -n openshift-kube-apiserver
```

Check etcd:

```bash
oc get pods -n openshift-etcd
```

Check the controller manager:

```bash
oc get pods -n openshift-kube-controller-manager
```

Check the scheduler:

```bash
oc get pods -n openshift-kube-scheduler
```

---

## 37. Check Certificate Signing Requests

Run:

```bash
oc get csr
```

If there are pending CSRs:

```bash
oc get csr
```

Review the CSR before approving it.

---

## 38. Check OpenShift API

Verify that the API is responding:

```bash
oc whoami
```

Run:

```bash
oc get namespaces
```

Run:

```bash
oc get projects
```

If these commands return successfully, the OpenShift API is accessible.

---

## 39. Final Cluster Validation

Run:

```bash
oc get nodes -o wide
```

```bash
oc get clusterversion
```

```bash
oc get clusteroperators
```

```bash
oc get pods -A
```

```bash
oc get csr
```

```bash
oc get namespaces
```

Finally:

```bash
oc whoami
```

The three control-plane nodes should be `Ready`, the Cluster Operators should become healthy, and the OpenShift API should be accessible.

---

## 40. Installation Complete

At this point the Agent-Based installation of OpenShift 4.22 is complete.

The final environment contains:

```text
                    Bastion
                       |
          +------------+------------+
          |            |            |
       Master1      Master2      Master3
       Control      Control      Control
        Plane        Plane        Plane
```

The Bastion provides:

```text
DNS
NTP / Chrony
HAProxy
OpenShift tooling
```

The mirror registry provides:

```text
OpenShift release images
```

The cluster contains:

```text
3 Control Plane Nodes
0 Worker Nodes
```

The installation can now proceed to post-installation configuration and validation.
