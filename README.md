# Cert Manager IBM Cloud Internet Services Webhook Solver

Cert Manager's ACME (automated certificate management environment) issuer type supports an optional 'webhook' solver, which can be used
to implement custom DNS01 challenge solving logic.

IBM Cloud Internet Services is not officially supported in cert-manager core, so if you want to automatically provision certificates with cert-manager using DNS challenges, you can use this repository to do so.
=======
This is useful if you need to use cert-manager with a DNS provider that is not
officially supported in cert-manager core.

## Why not in core?

As the project & adoption has grown, there has been an influx of DNS provider
pull requests to our core codebase. As this number has grown, the test matrix
has become un-maintainable and so, it's not possible for us to certify that
providers work to a sufficient level.

By creating this 'interface' between cert-manager and DNS providers, we allow
users to quickly iterate and test out new integrations, and then packaging
those up themselves as 'extensions' to cert-manager.

We can also then provide a standardised 'testing framework', or set of
conformance tests, which allow us to validate that a DNS provider works as
expected.

## Usage

### Prerequisites

You must have cert-manager already installed in your cluster.

See [installation instructions here](https://cert-manager.io/docs/installation/).

### Installation

You can install this webhook using helm:

```shell
helm install cert-manager-ibm-cis-webhook --set ibmCloudApiKey="<your IBM Cloud API key>"
```

### Issuer

Create or update an `Issuer` (or `ClusterIssuer`) to reference the newly installed solver:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: acme-dns-issuer
spec:
  acme:
    email: you@your.email.domain.com
    privateKeySecretRef:
      name: letsencrypt
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - dns01:
        webhook:
          config:
            ibmCloudCisCrns:
            - 'crn:v1:bluemix:public:internet-svcs:global:a/***:***::'
          groupName: acme.skills.network
          solverName: ibm-cloud-cis
      selector:
        dnsZones:
        - your.site.domain.com
```

After update your issuer, cert-manager should be able to automatically complete challenges for your certificates on IBM CIS-managed domains.

## Contributing

Contributions are welcome.
Please see [docs/CONTRIBUTING.md](./docs/CONTRIBUTING.md) to get started.
