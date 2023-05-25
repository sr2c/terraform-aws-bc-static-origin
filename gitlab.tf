data "aws_region" "this" {}

resource "gitlab_project_variable" "aws_region" {
  project   = var.gitlab_project
  key       = "AWS_DEFAULT_REGION"
  value     = data.aws_region.this.name
  protected = true
}

resource "gitlab_project_variable" "aws_access_key" {
  project   = var.gitlab_project
  key       = "AWS_ACCESS_KEY_ID"
  value     = aws_iam_access_key.deploy_user_key_v4.id
  protected = true
  masked    = true
}

resource "gitlab_project_variable" "aws_access_secret" {
  project   = var.gitlab_project
  key       = "AWS_SECRET_ACCESS_KEY"
  value     = aws_iam_access_key.deploy_user_key_v4.secret
  protected = true
  masked    = true
}
