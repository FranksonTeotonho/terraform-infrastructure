locals {
  s3_origin_id = "s3OriginId"
  lb_origin_id = "lbOriginId"
}

resource "aws_cloudfront_origin_access_identity" "s3_origin_access_identity" {
  comment = "s3 origin access"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = var.s3_bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_origin_access_identity.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = var.lb_dns
    origin_id   = local.lb_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 80
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    path_pattern           = "/api"
    target_origin_id       = local.lb_origin_id
    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    env        = var.env,
    managed_by = "Terraform"
  }
}

data "aws_iam_policy_document" "s3_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_bucket_arn}/*"]

    principals {
      identifiers = [aws_cloudfront_origin_access_identity.s3_origin_access_identity.iam_arn]
      type        = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy_allowing_cloudfront" {
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy_document.json
}

