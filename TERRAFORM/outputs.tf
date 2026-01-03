#Output para exibir o endereço do ALB criado para o cluster ECS contendo o endereço da API Livros.
output "api_livros_url" {
  value = "http://${aws_alb.application_load_balancer.dns_name}/livros"
}

output "codedeploy_bucket_name" {
  value = aws_s3_bucket.codedeploy_bucket.bucket
}