#Data responsavel por trazer as availability zones disponiveis na região que está sendo criado os recursos.
data "aws_availability_zones" "available_zones" {
  state = "available"
}

#Criação da VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "vpc-terraform"
  }
}

#Criação de duas subnets publicas em diferentes AZ, será utilizada pelo ALB.
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true
  count                   = 2

  tags = {
    Name = "subnet-public-${count.index}-terraform"
  }
}

/*
Criação de duas subnets privadas em diferentes AZ, para contemplar o cluster ECS, essas subnets
Irão utilizar NAT Gateway para as tarefas do ECS poderem sair para a internet de forma segura. 
*/
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${count.index + 2}.0/24"
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = false
  count                   = 2

  tags = {
    Name = "subnet-private-${count.index}-terraform"
  }
}

#Criação do internet gateway utilizado na subnets publicas.
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway-terraform"
  }
}

/*
Criação de dois elastic IP para ser associado em cada Nat Gateway.
*/

resource "aws_eip" "eip_one" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "eip-nat-gw-0-terraform"
  }
}

resource "aws_eip" "eip_two" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "eip-nat-gw-1-terraform"
  }
}

#Criação do Nat gateway na primeira subnet publica.
resource "aws_nat_gateway" "nat_gw_subnet0" {
  allocation_id = aws_eip.eip_one.id
  subnet_id     = aws_subnet.public_subnet.0.id
  depends_on    = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "Nat-gateway-subnet0-terraform"
  }
}

#Criação do Nat gateway na segunda subnet publica.
resource "aws_nat_gateway" "nat_gw_subnet1" {
  allocation_id = aws_eip.eip_two.id
  subnet_id     = aws_subnet.public_subnet.1.id
  depends_on    = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "Nat-gateway-subnet1-terraform"
  }
}

#Criação da rota para internet utilizando internet gateway, usado pelas subnets publicas.
resource "aws_default_route_table" "internet_access_public_subrnet" {
  default_route_table_id = aws_vpc.vpc.main_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "route-table-0-public-terraform"
  }
}

#Criação da route table 1 e da rota para a primeira subnet privada usar o Nat Gateway para sair para a internet.
resource "aws_route_table" "route_table_private_one" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_subnet0.id
  }

  tags = {
    Name = "route-table-0-private-terraform"
  }
}

#Criação da route table 2 e da rota para a primeira subnet privada usar o Nat Gateway para sair para a internet.
resource "aws_route_table" "route_table_private_two" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_subnet1.id
  }

  tags = {
    Name = "route-table-1-private-terraform"
  }
}

#Associação da route table 1 com a subnet privada 1
resource "aws_route_table_association" "route_table_association_one" {
  subnet_id      = aws_subnet.private_subnet.0.id
  route_table_id = aws_route_table.route_table_private_one.id
}

#Associação da route table 2 com a subnet privada 2
resource "aws_route_table_association" "route_table_association_two" {
  subnet_id      = aws_subnet.private_subnet.1.id
  route_table_id = aws_route_table.route_table_private_two.id
}

#Security Gateway utilizado pelo ALB, libera acesso a porta 80 para internet
resource "aws_security_group" "load_balancer_security_group" {
  name   = "load_balancer_security_group_terraform"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-terraform"
  }
}