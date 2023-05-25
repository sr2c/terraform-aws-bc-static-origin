resource "aws_iam_user" "deploy_user" {
  name = "${module.this.id}-deploy"
  tags = module.this.tags
}

resource "aws_iam_access_key" "deploy_user_key_v4" {
  user   = aws_iam_user.deploy_user.name
  status = "Active"
}

data "aws_iam_policy_document" "deploy_rw" {
  statement {
    sid = "AllowBucketList"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.this.arn
    ]
  }
  statement {
    sid = "AllowBucketRW"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
  statement {
    sid = "AllowCacheInvalidation"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      aws_cloudfront_distribution.this.arn
    ]
  }
}

resource "aws_iam_user_policy" "deploy_rw" {
  name   = "AllowIamUserBucketRW-${module.this.id}"
  user   = aws_iam_user.deploy_user.name
  policy = data.aws_iam_policy_document.deploy_rw.json
}
