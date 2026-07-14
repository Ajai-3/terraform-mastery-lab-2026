resource "aws_s3_bucket" "bucket_list" {
  count = 2

  bucket = var.bucket_names_list[count.index]

  tags = {
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "bucket_set" {
  for_each = var.bucket_names_set

  bucket = each.value

  tags = {
    Environment = var.Environment
    ManagedBy   = "Terraform"
  }

  depends_on = [ aws_s3_bucket.bucket_map ]
}

resource "aws_s3_bucket" "bucket_map" {
   for_each = var.bucket_names_map

   bucket = each.value

   tags = {
     Environment = var.Environment
     ManagedBy = "Terraform"
   }

   depends_on = [ aws_s3_bucket.bucket_list ]
}
