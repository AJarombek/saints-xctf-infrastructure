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
  required_version = "~> 1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
  }

  backend "s3" {
    bucket  = "andrew-jarombek-terraform-state"
    encrypt = true
    key     = "saints-xctf-infrastructure/s3-asset"
    region  = "us-east-1"
  }
}

locals {
  terraform_tag = "saints-xctf-infrastructure/s3-asset"
}

#-----------------------
# Existing AWS Resources
#-----------------------

data "aws_acm_certificate" "wildcard-saintsxctf-com-cert" {
  domain = "*.saintsxctf.com"
}

data "aws_route53_zone" "saintsxctf" {
  name = "saintsxctf.com."
}

#--------------------------------------
# New AWS Resources for S3 & CloudFront
#--------------------------------------

resource "aws_s3_bucket" "asset-saintsxctf" {
  bucket = "asset.saintsxctf.com"
  acl    = "private"

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

resource "aws_s3_bucket_policy" "asset-saintsxctf" {
  bucket = aws_s3_bucket.asset-saintsxctf.id
  policy = data.aws_iam_policy_document.asset-saintsxctf.json
}

data "aws_iam_policy_document" "asset-saintsxctf" {
  statement {
    sid = "CloudfrontOAI"

    principals {
      identifiers = [aws_cloudfront_origin_access_identity.origin-access-identity.iam_arn]
      type        = "AWS"
    }

    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.asset-saintsxctf.arn,
      "${aws_s3_bucket.asset-saintsxctf.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "asset-saintsxctf" {
  bucket = aws_s3_bucket.asset-saintsxctf.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_cloudfront_distribution" "asset-saintsxctf-distribution" {
  origin {
    domain_name = aws_s3_bucket.asset-saintsxctf.bucket_regional_domain_name
    origin_id   = "origin-bucket-${aws_s3_bucket.asset-saintsxctf.id}"

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

  comment             = "asset.saintsxctf.com CloudFront Distribution"
  default_root_object = "saintsxctf.png"

  # Extra CNAMEs for this distribution
  aliases = ["asset.saintsxctf.com"]

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
      headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string = false
    }

    target_origin_id = "origin-bucket-${aws_s3_bucket.asset-saintsxctf.id}"

    # Which protocols to use when accessing items from CloudFront
    viewer_protocol_policy = "redirect-to-https"

    # Determines the amount of time an object exists in the CloudFront cache
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The SSL certificate for CloudFront
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.wildcard-saintsxctf-com-cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name        = "asset-saintsxctf-com-cloudfront"
    Environment = "production"
    Terraform   = local.terraform_tag
  }
}

resource "aws_cloudfront_origin_access_identity" "origin-access-identity" {
  comment = "asset.saintsxctf.com origin access identity"
}

resource "aws_route53_record" "asset-saintsxctf-a" {
  name    = "asset.saintsxctf.com."
  type    = "A"
  zone_id = data.aws_route53_zone.saintsxctf.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.asset-saintsxctf-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.asset-saintsxctf-distribution.hosted_zone_id
  }
}

#-------------------
# S3 Bucket Contents
#-------------------

resource "aws_s3_bucket_object" "amazon-app-store-png" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "amazon-app-store.png"
  source       = "asset/amazon-app-store.png"
  etag         = filemd5("${path.cwd}/asset/amazon-app-store.png")
  content_type = "image/png"
}

resource "aws_s3_bucket_object" "app-store-png" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "app-store.png"
  source       = "asset/app-store.png"
  etag         = filemd5("${path.cwd}/asset/app-store.png")
  content_type = "image/png"
}

resource "aws_s3_bucket_object" "ben-f-jpg" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "ben-f.jpg"
  source       = "asset/ben-f.jpg"
  etag         = filemd5("${path.cwd}/asset/ben-f.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_bucket_object" "evan-g-jpg" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "evan-g.jpg"
  source       = "asset/evan-g.jpg"
  etag         = filemd5("${path.cwd}/asset/evan-g.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_bucket_object" "google-play-store-svg" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "google-play-store.svg"
  source       = "asset/google-play-store.svg"
  etag         = filemd5("${path.cwd}/asset/google-play-store.svg")
  content_type = "image/svg+xml"
}

resource "aws_s3_bucket_object" "joe-s-jpg" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "joe-s.jpg"
  source       = "asset/joe-s.jpg"
  etag         = filemd5("${path.cwd}/asset/joe-s.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_bucket_object" "lisa-g-jpg" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "lisa-g.jpg"
  source       = "asset/lisa-g.jpg"
  etag         = filemd5("${path.cwd}/asset/lisa-g.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_bucket_object" "saintsxctf-png" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "saintsxctf.png"
  source       = "asset/saintsxctf.png"
  etag         = filemd5("${path.cwd}/asset/saintsxctf.png")
  content_type = "image/png"
}

resource "aws_s3_bucket_object" "saintsxctf-vid-mp4" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "saintsxctf-vid.mp4"
  source       = "asset/saintsxctf-vid.mp4"
  etag         = filemd5("${path.cwd}/asset/saintsxctf-vid.mp4")
  content_type = "video/mp4"
}

resource "aws_s3_bucket_object" "thomas-c-jpg" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "thomas-c.jpg"
  source       = "asset/thomas-c.jpg"
  etag         = filemd5("${path.cwd}/asset/thomas-c.jpg")
  content_type = "image/jpeg"
}

resource "aws_s3_bucket_object" "trevor-b-jpg" {
  bucket       = aws_s3_bucket.asset-saintsxctf.id
  key          = "trevor-b.jpg"
  source       = "asset/trevor-b.jpg"
  etag         = filemd5("${path.cwd}/asset/trevor-b.jpg")
  content_type = "image/jpeg"
}