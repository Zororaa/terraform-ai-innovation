# Shared ALB & Private Hosted Zone

This Terraform module provisions:

- A **shared internal Application Load Balancer (ALB)**  
- A **security group** for the ALB  
- A **Route53 private hosted zone**  
- SSM parameters exposing ALB attributes and hosted zone metadata  
- Uses VPC details retrieved dynamically from **AWS SSM Parameter Store**

---

## Resources Created

### 1. **AWS Application Load Balancer (ALB)**

- Internal ALB
- Deployed in private subnets read from SSM (`/network/private_subnet_ids`)
- HTTPS/443 listener returning a default **404 Not Found** response
- Metadata stored in SSM parameters

### 2. **Security Group for the ALB**

Allows:
- HTTPS (443) inbound from VPC CIDR  
- All outbound traffic

### 3. **Route53 Private Hosted Zone**

- Hosted zone: `apollotyres.com`
- Associated with shared VPC from SSM (`/network/vpc_id`)

### 4. **SSM Parameters for Cross-Account & Cross-Module Use**

Exports:
- ALB ID  
- ALB ARN  
- ALB DNS name  
- ALB zone ID  
- ALB security group ID  
- HTTPS Listener ARN
- Hosted zone name  
- Hosted zone ID  

All stored under `/shared/...`

---

## Module Structure

This module references:

- VPC details from SSM parameters:
  - `/network/vpc_id`
  - `/network/private_subnet_ids`
  - `/network/vpc_cidr_block`
- Common tags defined in `locals`
