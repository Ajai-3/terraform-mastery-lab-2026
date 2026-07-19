# Terraform Website Hosting - Code Explanation

This document provides a detailed resource-by-resource and line-by-line explanation of the Infrastructure as Code (IaC) configuration inside the [`lab/terraform/`](./lab/terraform/) directory.

---

## 1. Local Variables (`local.tf`)

```terraform
locals {
  origin_id = "S3-${aws_s3_bucket.static_website_s3.id}"
  my_domain = "ajaiiii.cloud"
  sub_domain = "static-website.${local.my_domain}"
}
```

* **`origin_id`**: A unique identifier for the S3 origin block in CloudFront, dynamically incorporating the S3 bucket ID.
* **`my_domain`**: The registered base domain name used for hosting (e.g. `"ajaiiii.cloud"`).
* **`sub_domain`**: The specific sub-domain prefix (`"static-website.ajaiiii.cloud"`) mapped to our distribution.

---

## 2. Variables (`varables.tf`)

```terraform
variable "environment_name" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)"
  default     = "dev"
}

variable "s3_bucket_name" {
  type        = string
  description = "Globally unique name for the static website S3 bucket"
  default     = "static-website-dev-002285-n1"
}
```

* **`environment_name`**: Sets deployment tag metadata (defaults to `"dev"`).
* **`s3_bucket_name`**: The globally unique name required to allocate our target S3 storage namespace.

---

## 3. Storage Infrastructure (`main.tf`)

### S3 Bucket Creation
```terraform
resource "aws_s3_bucket" "static_website_s3" {
  bucket = var.s3_bucket_name
  tags = {
    Name        = "${var.s3_bucket_name}-bucket"
    Environment = var.environment_name
    ManagedBy   = "Terraform"
  }
}
```
* Creates the private S3 bucket utilizing the `var.s3_bucket_name` value and attaches resource tagging metadata.

### Public Access Block
```terraform
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.static_website_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```
* Explicitly blocks all public access to the S3 bucket at the storage level. All files are private; public clients must access the website strictly via the secure CloudFront CDN endpoint.

### Origin Access Control (OAC)
```terraform
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "OAC"
  description                       = "Origin Access Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
```
* Configures Origin Access Control. This mandates that CloudFront signs all requests forwarded to S3 using AWS SigV4, verifying authenticity.

### Bucket Access Policy
```terraform
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket     = aws_s3_bucket.static_website_s3.id
  depends_on = [aws_s3_bucket_public_access_block.public_block]

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowCloudFront",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : "${aws_s3_bucket.static_website_s3.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}
```
* Attaches an IAM bucket policy permitting `s3:GetObject` read actions exclusively to requests originating from our specific CloudFront distribution ARN.

---

## 4. File Upload Logic & MIME Mapping

```terraform
resource "aws_s3_object" "object" {
  for_each = fileset("${path.module}/../www", "**/*")

  bucket = aws_s3_bucket.static_website_s3.id
  key    = each.value
  source = "${path.module}/../www/${each.value}"
  etag   = filemd5("${path.module}/../www/${each.value}")

  content_type = lookup(
    {
      "html" = "text/html"
      "css"  = "text/css"
      "js"   = "application/javascript"
      "json" = "application/json"
      "png"  = "image/png"
      "jpg"  = "image/jpeg"
      "jpeg" = "image/jpeg"
      "svg"  = "image/svg+xml"
      "ico"  = "image/x-icon"
    },
    regexall("\\.([^.]+)$", each.value)[0][0],
    "application/octet-stream"
  )
}
```

* **`for_each = fileset(...)`**: Automatically scans the `www/` directory and generates a unique object path key for every matching asset.
* **`key` & `source`**: Maps the S3 relative path and matches the local file resource pathway on disk.
* **`etag = filemd5(...)`**: Calculates MD5 hashes. This lets Terraform detect if file contents have changed, uploading updates dynamically rather than re-uploading everything.
* **`content_type = lookup(...)`**: Parses the file extension using regex (`regexall`) and dynamically assigns correct browser MIME types (e.g. `text/html` or `text/css`) instead of default binary streams, preventing download prompts in user browsers.

---

## 5. Security & TLS Configuration

### ACM SSL Certificate
```terraform
resource "aws_acm_certificate" "site_cert" {
  provider  = aws.us_east_1
  domain_name       = local.sub_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
```
* Requests a public SSL/TLS Certificate for `"static-website.ajaiiii.cloud"`. Must be deployed in `us-east-1` since CloudFront requires globally accessible ACM certificates.

### DNS Cert Validation Record
```terraform
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.site_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.primary.zone_id
}
```
* Creates CNAME validation records in Route 53 to prove ownership of the domain to AWS Certificate Manager.

### Certificate Validation Trigger
```terraform
resource "aws_acm_certificate_validation" "site_cert" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.site_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
```
* Tracks and waits until validation is complete before marking the certificate as usable by CloudFront.

---

## 6. Global Content Delivery (CloudFront)

```terraform
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_website_s3.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [local.sub_domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.site_cert.certificate_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
```

* **`origin`**: Binds our regional S3 bucket domain name to the distribution, securing access via the OAC policy.
* **`default_root_object = "index.html"`**: Directs requests hitting `/` to fetch `index.html` by default.
* **`viewer_protocol_policy = "redirect-to-https"`**: Enforces encryption by redirecting all HTTP calls to secure HTTPS.
* **`aliases`**: Binds our custom domain alias `"static-website.ajaiiii.cloud"`.
* **`viewer_certificate`**: Links the validated ACM SSL Certificate to enable secure connections.

---

## 7. Domain Routing Configuration (Route 53)

```terraform
resource "aws_route53_zone" "primary" {
  name = local.my_domain
}

resource "aws_route53_record" "cloudfront" {
  for_each = aws_cloudfront_distribution.s3_distribution.aliases
  zone_id  = aws_route53_zone.primary.zone_id
  name     = each.value
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
```

* **`aws_route53_zone`**: Hosts the DNS zone for `"ajaiiii.cloud"`.
* **`aws_route53_record`**: Automatically sets up DNS Alias (A) records pointing `"static-website.ajaiiii.cloud"` directly to the CloudFront distribution domain name.
