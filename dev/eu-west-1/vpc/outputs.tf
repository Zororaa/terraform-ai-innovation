output "workload_vpc_tgw_attachment_id" {
  description = "Transit Gateway Attachment ID for workload VPC."
  value       = aws_ec2_transit_gateway_vpc_attachment.workload_vpc_attachment.id
}

output "gateway_vpc_tgw_attachment_id" {
  description = "Transit Gateway Attachment ID for gateway VPC."
  value       = aws_ec2_transit_gateway_vpc_attachment.gateway_vpc_attachment.id
}