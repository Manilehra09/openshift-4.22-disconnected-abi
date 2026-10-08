# Configure Custom CA

The disconnected registry uses a private lab CA.

## Generate Root CA

On the Bastion:

```bash
mkdir -p /root/registry-certs
cd /root/registry-certs

openssl genrsa -out rootCA.key 4096

openssl req -x509 -new -nodes \
  -key rootCA.key \
  -sha256 \
  -days 3650 \
  -out rootCA.crt \
  -subj "/CN=Lab Root CA"
```

## Generate Registry Certificate

Create an OpenSSL configuration containing the registry DNS name and IP address.

Example SANs:

```text
DNS:registry.example.com
DNS:mirror.example.com
IP:198.51.100.20
```

Generate the key and CSR:

```bash
openssl genrsa -out registry.key 4096

openssl req -new \
  -key registry.key \
  -out registry.csr
```

Sign the certificate with the lab CA.

## Trust the CA

On the Bastion:

```bash
cp rootCA.crt /etc/pki/ca-trust/source/anchors/lab-root-ca.crt
update-ca-trust
```

Verify:

```bash
curl https://registry.example.com:8443/v2/
```

Do not commit `rootCA.key`, `registry.key`, certificates or passwords to Git.
