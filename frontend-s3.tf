
###
# 1. S3 bucket
###
resource "aws_s3_bucket" "frontend_bucket" {
  bucket        = "roman-dev-frontend"
  force_destroy = true
}

###
# 2. CORS configuration
###
resource "aws_s3_bucket_cors_configuration" "frontend_cors" {
  bucket = aws_s3_bucket.frontend_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

###
# 3. Public Access Block (щоб можна було змінювати ACL/Policy)
###
resource "aws_s3_bucket_public_access_block" "frontend_bucket_block" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

###
# 4. Bucket Policy для публічного читання об’єктів
###
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.frontend_bucket_block]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"]
      Resource  = ["${aws_s3_bucket.frontend_bucket.arn}/*"]
    }]
  })
}


###
# 5. Website hosting
###
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

###
# 6. CloudFront distribution
###
resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  wait_for_deployment = true

  origin {
    origin_id   = "s3-frontend-origin"
    domain_name = aws_s3_bucket_website_configuration.frontend_website.website_domain

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-frontend-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}

###
# 7. Завантаження файлів з папки frontend/build
###
locals {
  build_files = fileset("${path.module}/frontend/build", "**")
}

resource "aws_s3_object" "frontend_files" {
  for_each = { for f in local.build_files : f => f }

  bucket = aws_s3_bucket.frontend_bucket.id
  key    = each.value
  source = "${path.module}/frontend/build/${each.value}"
  etag   = filemd5("${path.module}/frontend/build/${each.value}")
  content_type = lookup({
    html = "text/html",
    js   = "application/javascript",
    css  = "text/css",
    png  = "image/png",
    jpg  = "image/jpeg",
    svg  = "image/svg+xml",
    ico  = "image/x-icon",
    json = "application/json"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

###
# 8. Outputs
###
output "frontend_website_url" {
  description = "S3 Website URL"
  value       = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}

output "frontend_cdn_url" {
  description = "CloudFront URL"
  value       = aws_cloudfront_distribution.frontend_cdn.domain_name
}
