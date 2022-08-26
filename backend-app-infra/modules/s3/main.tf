resource "aws_s3_bucket" "s3" {
  bucket = "${var.env}-s3-frankson-teotonho"

  tags = {
    env        = var.env,
    managed_by = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = aws_s3_bucket.s3.id
  acl    = "private"
}

resource "aws_s3_object" "html" {
  bucket       = aws_s3_bucket.s3.bucket
  key          = "index.html"
  content      = file("${path.module}/files/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "js" {
  bucket = aws_s3_bucket.s3.bucket
  key    = "main.js"
  content = templatefile("${path.module}/files/main.tpl", {
    api_url = var.api_url
  })
  content_type = "application/javascript"
}

resource "aws_s3_bucket_website_configuration" "s3_site" {
  bucket = aws_s3_bucket.s3.bucket

  index_document {
    suffix = "index.html"
  }

  depends_on = [aws_s3_bucket.s3, aws_s3_object.html]
}

resource "aws_s3_bucket_public_access_block" "mybucket" {
  bucket              = aws_s3_bucket.s3.id
  block_public_acls   = true
  block_public_policy = true
}