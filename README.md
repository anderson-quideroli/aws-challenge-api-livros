<h1 align="center"> AWS Challenge - API Livros</h1>
<h4 align="center"> 
    :white_check_mark:  Projeto concluído  :white_check_mark:
</h4>

### Tópicos 

- [API Livros](#api-livros)

- [Ferramentas utilizadas](#ferramentas-utilizadas)

- [Pré-requisitos](#pré-requisitos)

- [Arquitetura](#arquitetura)

- [Topologia](#topologia)

- [CI/CD](#cicd)

- [Deploy local](#deploy-local)

- [Deploy na AWS](#%EF%B8%8Fdeploy-na-aws)
 
- [Autor](#autor)


## 💽API Livros

API Livros foi criada em Python 3.11 utilizando o framework de desenvolvimento web "Flask", no qual é possível efetuar ações utilizando métodos HTTP para consultar todos os livros, adição, remoção ou alteração de uma determinado livro.

A aplicação para esse projeto é conteinerizada e sua imagem é armazenada no Amazon Elastic Container Registry(ECR), onde é possível versionar a imagem docker, verificar vulnerabilidade, disponibilizar para recursos como ECS, funções lambdas ou para cluster EKS(Kubernetes).

## 🛠Ferramentas utilizadas

1. Docker - v24.0.2
2. Pyhon - v3.11.4
3. Flask - v2.3.3
4. Terraform - v1.5.4
5. Terraform Provider AWS - v5.10.0

## 🧩Pré-requisitos

Para o processo de CI/CD ocorra com sucesso é necessário a criação das variáveis e secrets no repositório que for armazenar o código.

- Secrets:
1. `AWS_ACCESS_KEY_ID` - Access Key do usuário com permissão para o deploy da imagem do ECR  e atualização da tarefa do ECS.
2. `AWS_SECRET_ACCESS_KEY` - Secret Key do usuário com permissão para o deploy da imagem do ECR  e atualização da tarefa do ECS.
3. `PGP_SECRET_SIGNING_PASSPHRASE` - Frase para criptografar o endereço da imagem que contem o ID da conta da AWS utilizada, no qual o GitHub interpreta como dados sensíveis e nesse caso, foi preciso criptografar o conteúdo enviado pelo output para o JOB build.

- Variaveis:
  
| Variavel | Valor |
|----------|-------|
| AWS_REGION | us-east-1 |
| CONTAINER_NAME | api-task |
| ECR_REPOSITORY | api-livros |
| ECS_CLUSTER | api-cluster |
| ECS_SERVICE | api-service |

## 📐Arquitetura

Foi escolhido como tecnologia o Elastic Container Service(ECS) da AWS, pois o ECS proporciona um ambiente escalável, com alta disponibilidade e failover em casos de falhas.

A orquestração do cluster ECS para essse projeto é realizada pelo Fargate, sem a necessidade de gerenciar servidores ou clusters de instâncias do Amazon EC2. 

O ambiente do Cluster está em multi-AZ, onde os containers serão distribuídos entre as availability zones us-east-1a e us-east-1b, utilizando quatro subnets entre duas privadas para contemplar o cluster ECS e duas publicas para liberar o acesso a API através do application load balancer.

As subnets privadas utilizam o nat gateway para poderem sair para a internet, pois é uma premissa do Cluster ECS, o ambiente possui redundância de Nat Gateway em cada subnet publica para disponibilidade em caso de incidentes na AZ.

O acesso ao cluster é liberado somente para o ALB e o ALB somente libera a porta 80/TCP para a internet.

A monitoração do Cluster ECS está sendo realizada pelo CloudWatch, onde monitora e exibe alertas de alto consumo de CPU, memória e se caso todas as tarefas estiverem paradas. 

As notificações dos alertas são enviadas por e-mail através do SNS, onde foi escritp dois e-mails no topico destinado para alertas do Cluster ECS.

Quando o ambiente é iniciado pela primeira vez o Terraform efetua o primeiro build da imagem Docker e salva no ECR com a tag 1.0, no qual é declarada na estrutura da task o endereço do ECR com o nome e tag da imagem.

## 📐Topologia

<div allign="center">
<img src="https://github.com/anderson-quideroli/aws-challenge-api-livros/assets/127318593/d8484871-325a-449d-a57a-8eba75a098fa.JPG" width="700px" />
</div>

## 🧱CI/CD

O pipeline de CI foi criado no Github Actions, onde efetua a validação inicial do código via RUFF a procura de erros no código fonte, efetua o build da imagem e faz push para o ECR.

A tag adicionada na imagem é o commit SHA e número do JOB que a gerou para facilitar a rastreabilidade da imagem com o JOB.

A estrutura utilizada para o CD, foi gerado no mesmo pipeline, porém criado um JOB diferente com steps para registrar a ECS task definition e efetuar o deploy dela no ECS Service.

## 💻Deploy Local


Porta local: 8080/tcp


1. Para efetuar o deploy local efetue o build da imagem docker:

```bash
docker build -t api-livros:latest .
```

2. Iniciar o ambiente:

```bash
docker compose up -d
```

3. Acesso a API Livros:
   
http://localhost:8080/livros

5. Stop do ambiente:

```bash
docker compose down
```

## ☁️Deploy na AWS

Para efetuar o deploy do ambiente na AWS, acesse o diretório TERRAFORM no projeto, efetue o deploy do ambiente:

```bash
terraform init
terraform plan
terraform apply
```
Ao término do deploy o Terraform ira exibir o endereço da API via output.

Ex.: api_livros_url =  "http://alb-app-ID-DA-CONTA.us-east-1.elb.amazonaws.com/livros"

## 👦Autor

Anderson Dias de Jesus Quideroli

**LinkedIn**: https://www.linkedin.com/in/anderson-dias-de-jesus-quideroli-625049b2/
