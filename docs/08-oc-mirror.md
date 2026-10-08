# Mirror OpenShift Release With oc-mirror v2

This lab mirrors OpenShift 4.22.15 to the disconnected registry.

## Verify Tools

```bash
oc version
kubectl version --client
openshift-install version
oc-mirror version
```

Example expected release:

```text
OpenShift 4.22.15
```

## Create ImageSetConfiguration

```bash
mkdir -p /root/ocp-4.22
cd /root/ocp-4.22

vim isc-ocp-4.22.15.yaml
```

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

## Mirror the Release

```bash
oc-mirror \
  -c /root/ocp-4.22/isc-ocp-4.22.15.yaml \
  --workspace file:///root/ocp-4.22/oc-mirror-workspace \
  --authfile /root/ocp-4.22/pull-secret-mirror.json \
  docker://registry.example.com:8443 \
  --v2
```

Check the generated workspace:

```bash
find /root/ocp-4.22/oc-mirror-workspace -type f | sort
```

The mirror operation should report that the release images were mirrored successfully.

## Generated IDMS

The generated ImageDigestMirrorSet will contain entries similar to:

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

The actual generated files should be taken from the `oc-mirror` workspace.

## Important

Never commit:

```text
pull-secret-mirror.json
```

Use the repository's example configuration only.
