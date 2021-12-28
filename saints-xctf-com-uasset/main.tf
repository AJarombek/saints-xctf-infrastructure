/**
 * Assets for the website located on an S3 bucket.  These assets belong to users of the websitee (ex: profile pictures,
 * group photos, etc.).  This S3 bucket has the domain uasset.saintsxctf.com
 * Author: Andrew Jarombek
 * Date: 1/20/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = ">= 3.70.0"
  }

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/s3-uasset"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "wildcard-saintsxctf-com-cert" {
  domain = "*.saintsxctf.com"
}

data "aws_acm_certificate" "wildcard-uasset-saintsxctf-com-cert" {
  domain = "*.uasset.saintsxctf.com"
}

data "aws_route53_zone" "saintsxctf" {
  name = "saintsxctf.com."
}

#--------------------------------------
# New AWS Resources for S3 & CloudFront
#--------------------------------------

resource "aws_s3_bucket" "uasset-saintsxctf" {
  bucket = "uasset.saintsxctf.com"
  acl = "private"

  tags = {
    Name = "uasset.saintsxctf.com"
  }

  website {
    index_document = "saintsxctf.png"
    error_document = "saintsxctf.png"
  }

  cors_rule {
    allowed_origins = ["https://saintsxctf.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
  }
}

resource "aws_s3_bucket_policy" "uasset-saintsxctf" {
  bucket = aws_s3_bucket.uasset-saintsxctf.id
  policy = data.aws_iam_policy_document.uasset-saintsxctf.json
}

data "aws_iam_policy_document" "uasset-saintsxctf" {
  statement {
    sid = "CloudfrontOAI"

    principals {
      identifiers = [aws_cloudfront_origin_access_identity.origin-access-identity.iam_arn]
      type = "AWS"
    }

    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.uasset-saintsxctf.arn,
      "${aws_s3_bucket.uasset-saintsxctf.arn}/*"
    ]
  }

  statement {
    sid = "PrivatePutObject"

    principals {
      identifiers = [data.aws_caller_identity.current.account_id]
      type = "AWS"
    }

    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.uasset-saintsxctf.arn}/*"]
  }
}

resource "aws_s3_bucket_public_access_block" "uasset-saintsxctf" {
  bucket = aws_s3_bucket.uasset-saintsxctf.id

  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}

resource "aws_cloudfront_distribution" "uasset-saintsxctf-distribution" {
  origin {
    domain_name = aws_s3_bucket.uasset-saintsxctf.bucket_regional_domain_name
    origin_id = "origin-bucket-${aws_s3_bucket.uasset-saintsxctf.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment = "uasset.saintsxctf.com CloudFront Distribution"
  default_root_object = "saintsxctf.png"

  # Extra CNAMEs for this distribution
  aliases = ["uasset.saintsxctf.com"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["HEAD", "GET", "OPTIONS"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["HEAD", "GET", "OPTIONS"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      headers = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string = false
    }

    target_origin_id = "origin-bucket-${aws_s3_bucket.uasset-saintsxctf.id}"

    # Which protocols to use when accessing items from CloudFront
    viewer_protocol_policy = "redirect-to-https"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.wildcard-saintsxctf-com-cert.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    Name = "uasset-saintsxctf-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "uasset.saintsxctf.com origin access identity"
}

resource "aws_cloudfront_distribution" "www-uasset-saintsxctf-distribution" {
  origin {
    domain_name = aws_s3_bucket.uasset-saintsxctf.bucket_regional_domain_name
    origin_id = "origin-bucket-${aws_s3_bucket.uasset-saintsxctf.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment = "www.uasset.saintsxctf.com CloudFront Distribution"
  default_root_object = "saintsxctf.png"

  # Extra CNAMEs for this distribution
  aliases = ["www.uasset.saintsxctf.com"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["HEAD", "GET", "OPTIONS"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["HEAD", "GET", "OPTIONS"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      headers = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string = false
    }

    target_origin_id = "origin-bucket-${aws_s3_bucket.uasset-saintsxctf.id}"

    # Which protocols to use when accessing items from CloudFront
    viewer_protocol_policy = "allow-all"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.wildcard-uasset-saintsxctf-com-cert.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    Name = "www-asset-saintsxctf-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_route53_record" "uasset-saintsxctf-a" {
  name = "uasset.saintsxctf.com."
  type = "A"
  zone_id = data.aws_route53_zone.saintsxctf.zone_id

  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.uasset-saintsxctf-distribution.domain_name
    zone_id = aws_cloudfront_distribution.uasset-saintsxctf-distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "www-uasset-saintsxctf-a" {
  name = "www.uasset.saintsxctf.com."
  type = "A"
  zone_id = data.aws_route53_zone.saintsxctf.zone_id

  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.www-uasset-saintsxctf-distribution.domain_name
    zone_id = aws_cloudfront_distribution.www-uasset-saintsxctf-distribution.hosted_zone_id
  }
}


#-------------------
# S3 Bucket Contents
#-------------------

resource "aws_s3_bucket_object" "saintsxctf-png" {
  bucket = aws_s3_bucket.uasset-saintsxctf.id
  key = "saintsxctf.png"
  source = "asset/saintsxctf.png"
  etag = filemd5("${path.cwd}/asset/saintsxctf.png")
  content_type = "image/png"
}