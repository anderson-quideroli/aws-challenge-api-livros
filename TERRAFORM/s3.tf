resource "aws_s3_bucket" "codedeploy_bucket" {
  bucket = "codedeploy-api-livros-${local.account_id}"
  force_destroy = true

  tags = {
    Name        = "codedeploy-api-livros"
    Environment = "Production"
  }
}