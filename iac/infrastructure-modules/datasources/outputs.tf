output "aws_region" {
  description = "Details about selected AWS region"
  value       = data.aws_region.selected
}

output "available_aws_availability_zones_names" {
  description = "A list of the Availability Zone names available to the account"
  value       = data.aws_availability_zones.available.names
}

output "available_aws_availability_zones_zone_ids" {
  description = "A list of the Availability Zone IDs available to the account"
  value       = data.aws_availability_zones.available.zone_ids
}

output "amazon_linux2_aws_ami_id" {
  description = "AMI ID of Amazon Linux 2"
  value       = data.aws_ami.amazon_linux2.id
}

output "ubuntu_1804_aws_ami_id" {
  description = "AMI ID of Ubuntu 18.04"
  value       = data.aws_ami.ubuntu_1804.id
}


output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "cloudfront_cors_s3_origin" {
  value = data.aws_cloudfront_origin_request_policy.managed_cors_s3origin.id
}

//output "cloudfront_cache_optimized" {
//  value = data.aws_cloudfront_cache_policy.managed_cache_optimized.id
//}
