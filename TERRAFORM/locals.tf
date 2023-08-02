#ID da Conta atual que está sendo criado os recursos.
locals {
  account_id = data.aws_caller_identity.current.account_id
}

#Região atual que está sendo criado os recursos.
locals {
  region_name = data.aws_region.current.name
}

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