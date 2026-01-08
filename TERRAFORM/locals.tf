
#Conjunto de tags que será padrão nos recursos criados.
locals {
  common_tags = {
    Environment = "Production"
    Owner       = "Anderson Quideroli"
    Managed-by  = "Terraform"
    Project     = "AWS-challenge"
    App         = "API Livros"
    Version     = "1.0"
  }
}

#Lista de e-mail utilizado no topico alerta_ecs_infraestrutura-terraform
locals {
  emails = ["anderson.quideroli2@gmail.com", "anderson.quideroli@hotmail.com"]
}
