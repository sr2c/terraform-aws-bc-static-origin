terraform {
  required_version = ">= 1.3.7"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.29.0"
      configuration_aliases = [aws, aws.us_east_1]
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 16.2.0"
    }
  }
}
