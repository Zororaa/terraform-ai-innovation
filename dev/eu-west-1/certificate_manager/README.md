# Certificate Manager

Imports the `*.apollotyres.com` wildcard TLS certificate into AWS Certificate Manager (ACM).

> **CERTIFICATE EXPIRES JAN 15, 2027**

## Setup

Certificate files in `/certificates/`:
- `star_apollotyres_com.crt` — Certificate body
- `bundle.crt` — CA chain

Private key injected from GitHub org secret `ATL_DOMAIN_TLS_CERT_PK` via `TF_VAR_atl_domain_tls_cert_pk`.

## Certificate Rotation

1. Replace certificate files in `/certificates/`
2. Update `ATL_DOMAIN_TLS_CERT_PK` GitHub org secret with new private key (PEM format)
3. Create PR, review plan, merge — ACM replaces the certificate automatically

Verify before committing:
```bash
openssl x509 -in certificates/star_apollotyres_com.crt -text -noout | grep "Not After"
```

## SSM Parameters

### Consumed

None.

### Produced

| Parameter | Description |
|-----------|-------------|
| `/shared/certificates/apollotyres_wildcard_arn` | ACM certificate ARN |

Consumed by: [shared_alb](../shared_alb/README.md).
