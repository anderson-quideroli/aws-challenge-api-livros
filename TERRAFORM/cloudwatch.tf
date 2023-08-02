/*
 Cloudwatch Alarmes do Cluster ECS
 Todas as alertas estão utilizando o mesmo topico para o envio de e-mail.
 */


#Alerta de alta utilização de CPU acima da média de 80% por 5 minutos.
resource "aws_cloudwatch_metric_alarm" "ecs_alert_High_cpuutilization" {
  alarm_name          = "${var.company}/${var.project}-ECS-High-CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  period              = "300"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  # second
  statistic         = "Average"
  threshold         = "80"
  alarm_description = ""

  metric_name = "CPUUtilization"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}",
    ServiceName = "${aws_ecs_service.app_service.name}",
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
  alarm_actions = [
    "${aws_sns_topic.alerta_ecs_infraestrutura.arn}",
  ]
}

#Alerta de alta utilização de memoria acima da média de 80% por 5 minutos.
resource "aws_cloudwatch_metric_alarm" "ecs_alert_High_memoryutilization" {
  alarm_name          = "${var.company}/${var.project}-ECS-High-MemoryUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  period              = "300"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  statistic         = "Average"
  threshold         = "80"
  alarm_description = ""

  metric_name = "MemoryUtilization"
  namespace   = "AWS/ECS"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}",
    ServiceName = "${aws_ecs_service.app_service.name}",
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
  alarm_actions = [
    "${aws_sns_topic.alerta_ecs_infraestrutura.arn}",
  ]
}

#Alerta se não tiver tarefas em execução no cluster ECS no periodo de 1 minuto.
resource "aws_cloudwatch_metric_alarm" "ecs_alert_task_execution_stopped" {
  alarm_name          = "${var.company}/${var.project}-ECS-Task-Execution-Stopped"
  comparison_operator = "LessThanOrEqualToThreshold"

  period              = "60"
  evaluation_periods  = "1"
  datapoints_to_alarm = 1

  statistic         = "Sum"
  threshold         = "0"
  alarm_description = ""

  metric_name = "RunningTaskCount"
  namespace   = "ECS/ContainerInsights"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}",
    ServiceName = "${aws_ecs_service.app_service.name}",
  }

  actions_enabled           = true
  insufficient_data_actions = []
  ok_actions                = []
  alarm_actions = [
    "${aws_sns_topic.alerta_ecs_infraestrutura.arn}",
  ]
}