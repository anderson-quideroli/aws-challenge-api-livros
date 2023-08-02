#Criação do topico alerta_ecs_infraestrutura para notificação de alertas pelo CloudWatch
resource "aws_sns_topic" "alerta_ecs_infraestrutura" {
  name = "alerta_ecs_infraestrutura-terraform"
}

/*
Criação da subscription para a infraestrura receber alertas, ela será associada
ao topico alerta_ecs_infraestrutura-terraform.
*/
resource "aws_sns_topic_subscription" "subscription_infraestrutura" {
  count     = length(local.emails)
  topic_arn = aws_sns_topic.alerta_ecs_infraestrutura.arn
  protocol  = "email"
  endpoint  = local.emails[count.index]
}