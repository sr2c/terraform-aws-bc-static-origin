module "lambda_origin_response" {
  providers = {
    aws = aws.us_east_1
  }
  source                            = "terraform-aws-modules/lambda/aws"
  function_name                     = "${module.this.id}-static-origin-response"
  description                       = "Add security headers"
  handler                           = "index.handler"
  runtime                           = "nodejs16.x"
  source_path                       = "${path.module}/lambda-origin-response/"
  lambda_at_edge                    = true
  cloudwatch_logs_retention_in_days = 14
  cloudwatch_logs_tags              = module.this.tags
  tags                              = module.this.tags
}

module "lambda_origin_request" {
  providers = {
    aws = aws.us_east_1
  }
  source                            = "terraform-aws-modules/lambda/aws"
  function_name                     = "${module.this.id}-static-origin-request"
  description                       = "Directories"
  handler                           = "index.handler"
  runtime                           = "nodejs16.x"
  source_path                       = "${path.module}/lambda-origin-request/"
  lambda_at_edge                    = true
  cloudwatch_logs_retention_in_days = 14
  cloudwatch_logs_tags              = module.this.tags
  tags                              = module.this.tags
}

module "weblite_origin_request" {
  providers = {
    aws = aws.us_east_1
  }
  source                            = "terraform-aws-modules/lambda/aws"
  function_name                     = "${module.this.id}-weblite-origin-request"
  description                       = "Directories"
  handler                           = "index.handler"
  runtime                           = "nodejs16.x"
  source_path                       = "${path.module}/lambda-origin-request-weblite/"
  lambda_at_edge                    = true
  cloudwatch_logs_retention_in_days = 14
  cloudwatch_logs_tags              = module.this.tags
  tags                              = module.this.tags
}

module "weblite_origin_response" {
  providers = {
    aws = aws.us_east_1
  }
  source                            = "terraform-aws-modules/lambda/aws"
  function_name                     = "${module.this.id}-weblite-origin-response"
  description                       = "Add security headers for weblite"
  handler                           = "index.handler"
  runtime                           = "nodejs16.x"
  source_path                       = "${path.module}/lambda-origin-response-weblite/"
  lambda_at_edge                    = true
  cloudwatch_logs_retention_in_days = 14
  cloudwatch_logs_tags              = module.this.tags
  tags                              = module.this.tags
}
