/**
 * Assets for the website located on an S3 bucket.  These assets belong to the website, not the users of the website.
 * This S3 bucket has the domain asset.saintsxctf.com
 * Author: Andrew Jarombek
 * Date: 1/20/2020
 */

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "andrew-jarombek-terraform-state"
    encrypt = true
    key = "saints-xctf-infrastructure/s3-asset"
    region = "us-east-1"
  }
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_acm_certificate" "wildcard-saintsxctf-com-cert" {
  domain = "*.saintsxctf.com"
}

data "aws_acm_certificate" "wildcard-asset-saintsxctf-com-cert" {
  domain = "*.asset.saintsxctf.com"
}

data "aws_route53_zone" "saintsxctf" {
  name = "saintsxctf.com."
}

#--------------------------------------
# New AWS Resources for S3 & CloudFront
#--------------------------------------

resource "aws_s3_bucket" "asset-saintsxctf" {
  bucket = "asset.saintsxctf.com"
  acl = "public-read"
  policy = file("${path.module}/policy.json")

  tags = {
    Name = "asset.saintsxctf.com"
  }

  website {
    index_document = "saintsxctf.png"
    error_document = "saintsxctf.png"
  }

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
  }
}

resource "aws_s3_bucket" "www-asset-saintsxctf" {
  bucket = "www.asset.saintsxctf.com"
  acl = "public-read"
  policy = file("${path.module}/www-policy.json")

  tags = {
    Name = "www.asset.saintsxctf.com"
  }

  website {
    redirect_all_requests_to = "https://asset.saintsxctf.com"
  }
}

resource "aws_cloudfront_distribution" "asset-saintsxctf-distribution" {
  origin {
    domain_name = aws_s3_bucket.asset-saintsxctf.bucket_regional_domain_name
    origin_id = "origin-bucket-${aws_s3_bucket.asset-saintsxctf.id}"

    s3_origin_config {
      origin_access_identity =
        aws_cloudfront_origin_access_identity.origin-access-identity.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment = "asset.saintsxctf.com CloudFront Distribution"
  default_root_object = "saintsxctf.png"

  # Extra CNAMEs for this distribution
  aliases = ["asset.saintsxctf.com"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["GET"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["GET"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }

    target_origin_id = "origin-bucket-${aws_s3_bucket.asset-saintsxctf.id}"

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
    Name = "asset-saintsxctf-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "asset.saintsxctf.com origin access identity"
}

resource "aws_cloudfront_distribution" "www-asset-saintsxctf-distribution" {
  origin {
    domain_name = aws_s3_bucket.www-asset-saintsxctf.bucket_regional_domain_name
    origin_id = "origin-bucket-${aws_s3_bucket.www-asset-saintsxctf.id}"

    s3_origin_config {
      origin_access_identity =
        aws_cloudfront_origin_access_identity.origin-access-identity-www.cloudfront_access_identity_path
    }
  }

  # Whether the cloudfront distribution is enabled to accept user requests
  enabled = true

  # Which HTTP version to use for requests
  http_version = "http2"

  # Whether the cloudfront distribution can use ipv6
  is_ipv6_enabled = true

  comment = "www.asset.saintsxctf.com CloudFront Distribution"
  default_root_object = "saintsxctf.png"

  # Extra CNAMEs for this distribution
  aliases = ["www.asset.saintsxctf.com"]

  # The pricing model for CloudFront
  price_class = "PriceClass_100"

  default_cache_behavior {
    # Which HTTP verbs CloudFront processes
    allowed_methods = ["GET"]

    # Which HTTP verbs CloudFront caches responses to requests
    cached_methods = ["GET"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }

    target_origin_id = "origin-bucket-${aws_s3_bucket.www-asset-saintsxctf.id}"

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
    acm_certificate_arn = data.aws_acm_certificate.wildcard-asset-saintsxctf-com-cert.arn
    ssl_support_method = "sni-only"
  }

  tags = {
    Name = "www-asset-saintsxctf-com-cloudfront"
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity-www" {
  comment = "www.asset.saintsxctf.com origin access identity"
}

resource "aws_route53_record" "asset-saintsxctf-a" {
  name = "asset.saintsxctf.com."
  type = "A"
  zone_id = data.aws_route53_zone.saintsxctf.zone_id

  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.asset-saintsxctf-distribution.domain_name
    zone_id = aws_cloudfront_distribution.asset-saintsxctf-distribution.hosted_zone_id
  }
}

resource "aws_route53_record" "www-asset-saintsxctf-a" {
  name = "www.asset.saintsxctf.com."
  type = "A"
  zone_id = data.aws_route53_zone.saintsxctf.zone_id

  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.www-asset-saintsxctf-distribution.domain_name
    zone_id = aws_cloudfront_distribution.www-asset-saintsxctf-distribution.hosted_zone_id
  }
}