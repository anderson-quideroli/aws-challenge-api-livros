#Criação do ALB utilizado no Cluster ECS.
resource "aws_alb" "application_load_balancer" {
  name               = "alb-app"
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnet.*.id
  security_groups    = ["${aws_security_group.load_balancer_security_group.id}"]

  tags = {
    Name = "alb-app"
  }
}

/*
Criação do target group para ALB alb-app, ele ira verificar a integrida da aplicação verificando a porta 8080 da tarrefa pelo IP 
no path /livros pois retorna os dados da API com sucesso, gerando codigo 200.
O algoritimo utilizado sera o default round-robin.
*/
resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    path                = "/livros"
    port                = "8080"
    interval            = "30"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "alb-tg-app"
  }
}


#Listener do ALB na porta 80
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn #  load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # target group
  }
}