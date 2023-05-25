output "iam_user_access_key_id" {
  value     = aws_iam_access_key.deploy_user_key_v4.id
  sensitive = true
}

output "iam_user_secret_access_key" {
  value     = aws_iam_access_key.deploy_user_key_v4.secret
  sensitive = true
}

output "primary_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}