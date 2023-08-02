#Data resposanvel na coleta do dados da conta da região atual que está sendo criado os recursos.
data "aws_caller_identity" "current" {}

#Data responsavel na coleta da região atual que está sendo criado os recursos.
data "aws_region" "current" {}

/*
Criação do ECR para contemplar a imagem docker da API Livros.
Obs.: as tag foi adicionado como imutavel, pois será utilizado o sha gerado pelo GitHub como identificador unico da imagem e imutavel.
*/

resource "aws_ecr_repository" "api-livros" {
  name                 = "api-livros"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  #Efetuado login no ECR e gera o token de conexão utilizado pelo docker para build a imagem.
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${local.region_name} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${local.region_name}.amazonaws.com"
  }
  #Build da imagem docker da API Livros
  provisioner "local-exec" {
    command     = "docker build -t ${local.account_id}.dkr.ecr.${local.region_name}.amazonaws.com/api-livros:1.0 ."
    working_dir = "../"
  }

  #Push da imagem docker para o ECR api-livros
  provisioner "local-exec" {
    command     = "docker push ${local.account_id}.dkr.ecr.${local.region_name}.amazonaws.com/api-livros:1.0"
    working_dir = "../"
  }
}