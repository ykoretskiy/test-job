resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin access identity for S3 website"
}

resource "aws_cloudfront_distribution" "lambda_distribution" {
  depends_on = [
    aws_lambda_function.increase_number_lambda,
    aws_lambda_function.auth_lambda
  ]

  origin {
    domain_name = replace(replace(aws_lambda_function_url.increase_number_lambda.function_url, "https://", ""), "/", "")
    origin_id   = replace(replace(aws_lambda_function_url.increase_number_lambda.function_url, "https://", ""), "/", "")
    custom_origin_config {
      https_port             = 443
      http_port              = 80
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id         = split("/", aws_lambda_function_url.increase_number_lambda.function_url)[2]
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"

    allowed_methods = [
      "GET",
      "HEAD"
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = "${aws_lambda_function.auth_lambda.arn}:${aws_lambda_function.auth_lambda.version}"
      include_body = true
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  enabled = true
  tags    = local.tags
}


output "cloudfront_url" {
  value = aws_cloudfront_distribution.lambda_distribution.domain_name
}