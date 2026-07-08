output "vpc_id" {
  value = module.workload_vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.workload_vpc.private_subnets
}

output "vpc_cidr_block" {
  value = module.workload_vpc.vpc_cidr_block
}

output "workload_vpc_tgw_attachment_id" {
  description = "Transit Gateway Attachment ID for workload VPC."
  value       = aws_ec2_transit_gateway_vpc_attachment.workload_vpc_attachment.id
}