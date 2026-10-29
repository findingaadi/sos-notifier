resource "aws_s3_bucket" "site" {
  bucket_prefix = "sos-notifier-site-"
  force_destroy = true # lets `terraform destroy` delete the bucket even when it has files in it
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

# New buckets block all public access; open just enough for a bucket policy to allow public reads
resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "site_public_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket     = aws_s3_bucket.site.id
  policy     = data.aws_iam_policy_document.site_public_read.json
  depends_on = [aws_s3_bucket_public_access_block.site]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  content_type = "text/html"
  content = templatefile("${path.module}/frontend/index.html", {
    api_url = "${aws_apigatewayv2_api.sos.api_endpoint}/sos"
  })
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.site.id
  key          = "style.css"
  content_type = "text/css"
  source       = "${path.module}/frontend/style.css"
  etag         = filemd5("${path.module}/frontend/style.css")
}