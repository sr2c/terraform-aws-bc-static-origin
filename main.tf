data "aws_caller_identity" "this" {}

resource "aws_s3_bucket" "this" {
  bucket = module.this.id
  tags   = module.this.tags
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.this.id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.this.account_id}:distribution/${aws_cloudfront_distribution.this.id}"]
      variable = "AWS:SourceArn"
    }

  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = module.this.id
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id                = "S3-${module.this.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  dynamic "origin" {
    for_each = var.matrix_homeserver == null ? [] : ["this"]
    content {
      domain_name = var.matrix_homeserver
      origin_id   = "matrix-${var.matrix_homeserver}"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  dynamic "origin" {
    for_each = var.keanu_convene_path == null ? [] : ["this"]
    content {
      domain_name = "letsconvene.im"
      origin_id   = "convene-letsconvene.im"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  dynamic "origin" {
    for_each = var.cleaninsights_domain_name == null ? [] : ["this"]
    content {
      domain_name = var.cleaninsights_domain_name
      origin_id   = "ci-${var.cleaninsights_domain_name}"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  origin {
    domain_name = "sentry.gpcmdln.net"
    origin_id   = "sentry-gpcmdln.net"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${module.this.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0 # 3600
    max_ttl                = 0 # 86400

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = module.lambda_origin_request.lambda_function_qualified_arn
    }
    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = module.lambda_origin_response.lambda_function_qualified_arn
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.keanu_convene_path == null ? [] : ["this"]
    content {
      path_pattern     = "/${var.keanu_convene_path}/config.json"
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "S3-${module.this.id}"

      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
      origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin

      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 0 # 3600
      max_ttl                = 0 # 86400

      lambda_function_association {
        event_type = "origin-request"
        lambda_arn = module.lambda_origin_request.lambda_function_qualified_arn
      }
      lambda_function_association {
        event_type = "origin-response"
        lambda_arn = module.lambda_origin_response.lambda_function_qualified_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.keanu_convene_path == null ? [] : ["this"]
    content {
      path_pattern     = "/${var.keanu_convene_path}/*"
      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "convene-letsconvene.im"

      forwarded_values {
        query_string = false

        cookies {
          forward = "none"
        }
      }

      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 0 # 3600
      max_ttl                = 0 # 86400

      lambda_function_association {
        event_type = "origin-request"
        lambda_arn = module.weblite_origin_request.lambda_function_qualified_arn
      }
      lambda_function_association {
        event_type = "origin-response"
        lambda_arn = module.weblite_origin_response.lambda_function_qualified_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.matrix_homeserver == null ? [] : ["/_matrix/*"]
    content {
      path_pattern             = ordered_cache_behavior.value
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD"]
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
      origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader
      compress                 = true
      target_origin_id         = "matrix-${var.matrix_homeserver}"
      viewer_protocol_policy   = "redirect-to-https"
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.cleaninsights_domain_name == null ? [] : ["/cleaninsights.php", "/matomo.php", "/matomo.js"]
    content {
      path_pattern             = ordered_cache_behavior.value
      allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods           = ["GET", "HEAD"]
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
      origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader
      compress                 = true
      target_origin_id         = "ci-${var.cleaninsights_domain_name}"
      viewer_protocol_policy   = "redirect-to-https"
    }
  }

  ordered_cache_behavior {
    path_pattern             = "/sentry/*"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # CachingDisabled
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # AllViewerExceptHostHeader
    compress                 = true
    target_origin_id         = "sentry-gpcmdln.net"
    viewer_protocol_policy   = "redirect-to-https"

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = module.lambda_origin_request.lambda_function_qualified_arn
    }
  }

  dynamic "custom_error_response" {
    for_each = [
      400,
      403,
      405,
      414,
      416
    ]
    content {
      error_caching_min_ttl = 10
      error_code            = custom_error_response.value
      response_code         = custom_error_response.value
      response_page_path    = "/error.html"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = module.this.tags
}


resource "aws_s3_object" "weblite_config" {
  bucket  = aws_s3_bucket.this.id
  key     = "${var.keanu_convene_path}/config.json"
  content = var.keanu_convene_config
}
