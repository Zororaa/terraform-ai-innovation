
# resource "aws_ssm_parameter" "shared_alb_id" {
#   name           = "/shared/shared_alb/id"
#   type           = "String"
#   insecure_value = aws_lb.shared_alb.id
# }
#
# resource "aws_ssm_parameter" "shared_alb_arn" {
#   name           = "/shared/shared_alb/arn"
#   type           = "String"
#   insecure_value = aws_lb.shared_alb.arn
# }
#
# resource "aws_ssm_parameter" "shared_alb_dns_name" {
#   name           = "/shared/shared_alb/dns_name"
#   type           = "String"
#   insecure_value = aws_lb.shared_alb.dns_name
# }
#
# resource "aws_ssm_parameter" "shared_alb_zone_id" {
#   name           = "/shared/shared_alb/zone_id"
#   type           = "String"
#   insecure_value = aws_lb.shared_alb.zone_id
# }
#
# resource "aws_ssm_parameter" "shared_alb_security_group_id" {
#   name           = "/shared/shared_alb/security_group_id"
#   type           = "String"
#   insecure_value = aws_security_group.shared_alb_sg.id
# }
#
# resource "aws_ssm_parameter" "shared_alb_https_listener_arn" {
#   name           = "/shared/shared_alb/https_listener_arn"
#   type           = "String"
#   insecure_value = aws_lb_listener.https.arn
# }
#
# resource "aws_ssm_parameter" "private_hosted_zone_name" {
#   name           = "/shared/hosted_zone/private_hosted_zone_name"
#   type           = "String"
#   insecure_value = aws_route53_zone.private.name
# }
#
# resource "aws_ssm_parameter" "private_hosted_zone_id" {
#   name           = "/shared/hosted_zone/private_hosted_zone_id"
#   type           = "String"
#   insecure_value = aws_route53_zone.private.id
# }