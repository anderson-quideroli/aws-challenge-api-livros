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
}