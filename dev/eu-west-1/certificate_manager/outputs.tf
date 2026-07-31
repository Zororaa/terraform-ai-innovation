output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.apollotyres_wildcard.arn
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.apollotyres_wildcard.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.apollotyres_wildcard.status
}
