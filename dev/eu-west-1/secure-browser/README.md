# Secure Browser

AWS WorkSpaces Secure Browser portal for zero-trust access to internal web applications without VPN.

## Benefits over VPN

| Feature | VPN | Secure Browser |
|---------|-----|----------------|
| Data residency | Downloaded to device | Only encrypted pixels streamed |
| Device requirements | Managed device + agents | Any Chrome/Edge (BYOD) |
| Network risk | Lateral movement possible | Sessions isolated in disposable containers |
| Maintenance | Patch VPN concentrators | Fully managed by AWS |

## User Flow

1. User navigates to the Secure Browser Portal URL
2. Portal redirects to central AWS Identity Center
3. User authenticates with corporate credentials + MFA
4. Identity Center sends SAML assertion to the portal
5. AWS spins up a disposable Chrome container in the Gateway VPC
6. Remote browser connects to internal resources (ports 80, 443) and streams visual output

## Cross-Account SAML Federation

| Component | Account | Role |
|-----------|---------|------|
| Service Provider (SP) | Member account (this workspace) | WorkSpaces Web Portal |
| Identity Provider (IdP) | Management account | Customer Managed Application in Identity Center |

The `aws_workspacesweb_identity_provider` resource links these by uploading IdP metadata into the portal.

## Setup

1. Deploy the `secure-browser` module (omit `idp_saml_metadata_xml` initially)
2. Note the ACS URL and Entity ID from the AWS Console
3. Create a SAML 2.0 Customer Managed Application in Identity Center (management account)
4. Set ACS URL and Audience from step 2
5. Assign Identity Center group(s) to the application
6. Download IdP metadata XML and place in `idp-metadata/`
7. Set `idp_saml_metadata_xml` in the module call and re-apply

## SSM Parameters

### Consumed

| Parameter | Source | Description |
|-----------|--------|-------------|
| `/network/gateway_vpc_id` | [vpc](../vpc/README.md) | Gateway VPC for portal deployment |
| `/network/gateway_vpc_private_subnet_ids` | [vpc](../vpc/README.md) | Subnets for browser containers |
| `/network/gateway_vpc_cidr_block` | [vpc](../vpc/README.md) | Gateway VPC CIDR |

### Produced

None.
