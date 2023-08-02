/*
Role reponsavel por atribui permissão para a tarefa do ECS ter acesso no ECR para download da imagem, solicitar token de acesso e
na geração e envio de logs.  
*/
resource "aws_iam_role" "iam_role_ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

#Associação da politica AmazonECSTaskExecutionRolePolicy na role ecsTaskExecutionRole.
resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicyAttach" {
  role       = aws_iam_role.iam_role_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}