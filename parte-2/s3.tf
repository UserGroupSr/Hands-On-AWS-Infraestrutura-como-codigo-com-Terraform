# Bucket S3 para armazenar os arquivos do site do workshop
resource "aws_s3_bucket" "site" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = var.common_tags
}

# Bloqueio de acesso público ao bucket — todas as 4 opções habilitadas
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload do arquivo index.html para o bucket S3
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${var.site_files_path}/index.html"
  content_type = "text/html"
  etag         = filemd5("${var.site_files_path}/index.html")
}

# Upload do arquivo app.js para o bucket S3
resource "aws_s3_object" "app_js" {
  bucket       = aws_s3_bucket.site.id
  key          = "app.js"
  source       = "${var.site_files_path}/app.js"
  content_type = "application/javascript"
  etag         = filemd5("${var.site_files_path}/app.js")
}

# Upload do arquivo style.css para o bucket S3
resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.site.id
  key          = "style.css"
  source       = "${var.site_files_path}/style.css"
  content_type = "text/css"
  etag         = filemd5("${var.site_files_path}/style.css")
}

# Upload do logotipo do User Group para o bucket S3
resource "aws_s3_object" "logo" {
  bucket       = aws_s3_bucket.site.id
  key          = "img/logo.png"
  source       = "${var.site_files_path}/img/logo.png"
  content_type = "image/png"
  etag         = filemd5("${var.site_files_path}/img/logo.png")
}
