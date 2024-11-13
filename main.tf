#create s3
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.bucket}"
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "Access" {
    bucket = aws_s3_bucket.my_bucket.id

    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
  
}

resource "aws_s3_bucket_acl" "ACL" {
    bucket = aws_s3_bucket.my_bucket.id
    acl    = "public-read"
    depends_on = [ aws_s3_bucket_ownership_controls.owner,
    aws_s3_bucket_public_access_block.Access, ]
  
}
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [ aws_s3_bucket_acl.ACL ]
}
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.my_bucket.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
  etag = filemd5("index.html")
}
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.my_bucket.id
  key = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}
