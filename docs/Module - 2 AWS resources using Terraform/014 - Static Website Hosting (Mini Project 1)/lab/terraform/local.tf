locals {
  origin_id = "S3-${aws_s3_bucket.static_website_s3.id}"
  my_domain = "ajaiiii.cloud"
  sub_domain = "static-website.${local.my_domain}"
}