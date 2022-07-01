resource "aws_s3_bucket" "bucket" {
  bucket = "my-bucket-${random_pet.this.id}"
}

resource "aws_s3_object" "object" {
  bucket  = aws_s3_bucket.bucket.id
  key     = "telegram_bot_token"
  content = var.telegram_bot_token
  etag    = md5(var.telegram_bot_token)
}
