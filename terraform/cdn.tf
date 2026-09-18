# Distribution CloudFront placée devant le site statique S3
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribution du site statique M-Motors"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  # Origine contenant les fichiers du site
  origin {
    domain_name = aws_s3_bucket_website_configuration.frontend.website_endpoint
    origin_id   = "${var.project_name}-frontend-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Comportement appliqué à toutes les requêtes
  default_cache_behavior {
    target_origin_id = "${var.project_name}-frontend-origin"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  # Aucune restriction géographique
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Certificat HTTPS fourni automatiquement par CloudFront
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.project_name}-frontend-cdn"
    Environment = "production"
  }
}

