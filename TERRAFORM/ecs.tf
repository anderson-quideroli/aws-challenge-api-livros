#Criação do cluster ECS
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "api-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


/*
Criação da tarefa a ser usada pelo serviço do cluster ECS
Essa tarefa busca a imagem do ECR da API Livros na versão 1.0.
*/
resource "aws_ecs_task_definition" "app_task" {
  family                   = "api-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "api-task",
      "image": "${local.account_id}.dkr.ecr.${local.region_name}.amazonaws.com/api-livros:1.0",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = "arn:aws:iam::${local.account_id}:role/ecsTaskExecutionRole"
}


/*
Criação do serviço do cluster ECS, responsavel em criar as tarefas do cluster(Containers).
e atribuir a tarefa ao target group associado ao ALB.
*/
resource "aws_ecs_service" "app_service" {
  name            = "api-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.app_count #Quantidade de replicadas do container localizada no variable.tf
  depends_on      = [aws_nat_gateway.nat_gw_subnet0, aws_nat_gateway.nat_gw_subnet1]
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.app_task.family
    container_port   = 8080 #Porta que API Livros ira trabalhar
  }

  network_configuration {
    subnets          = aws_subnet.private_subnet.*.id
    assign_public_ip = false
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
}

#Criação do ECS Auto Scalling target
resource "aws_appautoscaling_target" "api_to_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.app_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#Criação policy para escalonar utilizando como metrica o uso de memoria, policy do tipo Target tracking scaling
resource "aws_appautoscaling_policy" "api_target_memory" {
  name               = "api_target_memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api_to_target.resource_id
  scalable_dimension = aws_appautoscaling_target.api_to_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api_to_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80  #Percentual de uso de memoria para Auto Scalling ser acionado
    scale_in_cooldown  = 300 #A quantidade de tempo, em segundos, após a conclusão de uma atividade de redução antes que outra atividade de redução possa começar
    scale_out_cooldown = 300 #A quantidade de tempo, em segundos, de espera para que uma atividade de expansão anterior entre em vigor.
  }
}


#Criação policy para escalonar utilizando como metrica o uso de CPU, policy do tipo Target tracking scaling
resource "aws_appautoscaling_policy" "api_target_cpu" {
  name               = "api_target_cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api_to_target.resource_id
  scalable_dimension = aws_appautoscaling_target.api_to_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api_to_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 80  #Percentual de uso de CPU para Auto Scalling ser acionado
    scale_in_cooldown  = 300 #A quantidade de tempo, em segundos, após a conclusão de uma atividade de redução antes que outra atividade de redução possa começar
    scale_out_cooldown = 300 #A quantidade de tempo, em segundos, de espera para que uma atividade de expansão anterior entre em vigor.
  }
}


#Security group utilizando pelo serviço do ECS para liberar acesso do ALB nas tarefas.
resource "aws_security_group" "service_security_group" {
  name   = "service-security-group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "service-ecs-sg-terraform"
  }
}