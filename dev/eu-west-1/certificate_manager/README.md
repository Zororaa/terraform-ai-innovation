# Certificate Manager

Imports `*.apollotyres.com` TLS certificate into AWS Certificate Manager (ACM) for use by ALB, API Gateway, and CloudFront.

**Certificate:** Wildcard `*.apollotyres.com`
**Storage:** ARN stored in SSM at `/shared/certificates/apollotyres_wildcard_arn`

> **⚠️⚠️ CERTIFICATE EXPIRES JAN 15 2027 ⚠️⚠️ **

## Setup

Certificate files in `/certificates/`:
- `star_apollotyres_com.crt` - Certificate body
- `bundle.crt` - CA chain

Private key injected from GitHub org secret `ATL_DOMAIN_TLS_CERT_PK` via `TF_VAR_atl_domain_tls_cert_pk`.

## Certificate Rotation

### 1. Update Files
```bash
# Replace certificate files in /certificates/ directory
cp new_cert.crt certificates/star_apollotyres_com.crt
cp new_bundle.crt certificates/bundle.crt
 
# Verify
openssl x509 -in certificates/star_apollotyres_com.crt -text -noout | grep "Not After"
```

### 2. Update GitHub Secret
Update `ATL_DOMAIN_TLS_CERT_PK` in org settings with new private key (PEM format).

### 3. Deploy
```bash
git add certificates/
git commit -m "Rotate *.apollotyres.com certificate"
# Create PR, review plan, merge
```

ACM will replace the certificate and update the SSM parameter. Dependent resources pick up the new ARN automatically.

## Usage in Other Workspaces

```hcl
data "aws_ssm_parameter" "certificate_arn" {
  name = "/shared/certificates/apollotyres_wildcard_arn"
}

resource "aws_lb_listener" "https" {
  certificate_arn = data.aws_ssm_parameter.certificate_arn.value
  # ...
}
```

## Troubleshooting

**Private key mismatch:** Verify key matches certificate:
```bash
openssl x509 -noout -modulus -in certificates/star_apollotyres_com.crt | openssl md5
openssl rsa -noout -modulus -in private_key.pem | openssl md5  # Should match
```

**Chain invalid:** Ensure `bundle.crt` has intermediate cert first, then root cert.
