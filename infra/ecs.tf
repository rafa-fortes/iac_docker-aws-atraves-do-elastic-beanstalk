# O Amazon Elastic Container Service (Amazon ECS) é um serviço de gerenciamento
# de contêineres altamente rápido e escalável. Você pode usá-lo para executar,
# interromper e gerenciar contêineres em um cluster. 

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  #version = "0.12.19"
  
  name               = var.ambiente
  container_insights = true                            # Controla se o cluster do ECS tem insigths disponíveis, ou seja, ele consegue ver as configurações do nosso container, para ele ter algumas ideias do que estar acontecendo nesses containers. (vai nos ajudar a montar alguns logs, algumas métricas,)
  capacity_providers = ["FARGATE"]                     # controla para nós quais instâncias devem ser ligadas, quais devem ser desligadas e como as instâncias devem ser manejadas
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
    }
  ]
}


# Acabamos de criar aqui no ECS o nosso cluster, que é o que vai definir quais são as instâncias,
# como é que vai ser manejado as instâncias que vamos criar.
# Falamos aqui que queremos instâncias do tipo fargate. Com isso, temos o nosso cluster pronto.
# Clusters que são as nossas máquinas virtuais, as nossas instâncias que vão ser gerenciadas pelo Fargate.

# Agora, precisamos colocar a nossa aplicação nessas instâncias, dentro desse Clusters.
# E vamos conseguir fazer isso através de uma task.


# TASK 
resource "aws_ecs_task_definition" "Django-API" {         # Quando executamos uma tarefa não executamos ela uma vez, podemos executa-la várias vezes, por isso é uma família de tasks.
  family                   = "Django-API"                 # Essa família de task vamos chamar de family = "Django-API", já que a nossa aplicação é uma API que está sendo feito em Django.
  requires_compatibilities = ["FARGATE"]                  # Ele precisa de compatibilidade com o Fargate, temos o requires_compatibilities, ou seja, o que precisamos de compatibilidade, o que requeremos de compatibilidade, no caso, ["FARGATE"].
  network_mode             = "awsvpc"
  cpu                      = 256                          # consultas: https://docs.aws.amazon.com/pt_br/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn       # Nós criamos aqui um perfil com o cargo que precisamos para poder executar a nossa aplicação porque a nossa aplicação vai precisar acessar o ECR, temos que usar esse perfil aqui na nossa task. (consulta: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition)
  container_definitions    = jsonencode(                  # Configurações do container, vamos escrevendo na forma de Json do terraform que é: jsonencode.
    [
      {
        "name"      = "producao"                                                     # Nome do container.
        "image"     = "035977729381.dkr.ecr.us-west-2.amazonaws.com/producao:v1"
        "cpu"       = 256                                                            # Limite da cpu do container.
        "memory"    = 512                                                            # Limite da memória do container.
        "essential" = true                                                           # Coisas são essenciais para manejar o nosso container.
        "portMappings" = [
          {
            "containerPort" = 8000                                                   # O ”containerPort”= 8000, que é a porta do nosso container.
             "hostPort"     = 8000                                                   # O "hostPort" = 8000, Vamos passar também para a porta 8000. Já configuramos o load balancer, já configuramos grupo de segurança, tudo isso para usar a porta 8000, então vamos manter tudo na porta 8000 para não termos nenhum tipo de confusão.
          }
        ]
      }
    ]
  )
}


# Criando nosso Service ou serviço, que vai definir qual task deve ser executada dentro de qual cluster.
# Esse serviço vai cuidar dessa parte e fazer o link entre nossa task e o cluster
# para termos só um de cada, precisamos do serviço, se no futuro quisermos expandir para mais.
# E ele também vai trazer umas configurações, 
# como por exemplo a configuração de qual load balancer que vamos utilizar.


resource "aws_ecs_service" "Django-API" {                                         # O nome desse serviço, eu vou dar o mesmo nome que demos aqui em cima, "Django-API". Nesse caso, não vai ter problema de dar o mesmo nome, porque o nome lógico para o Terraform vai ser resource "aws-ecs-task-definition” “Django-API", e o que vamos criar agora é o resource "aws-ecs-service” “Django-API". São dois nomes lógicos diferentes, estar válido.
  name            = "Django-API"
  cluster         = module.ecs.ecs_cluster.id                                         # Qual vai ser o cluster que vamos utilizar? O cluster criamos aqui em cima através do módulo, cluster = module.ecs.cluster_id.
  task_definition = aws_ecs_task_definition.Django-API.arn
  desired_count   = 3                                                             # Número de instâncias da definição de tarefa a serem colocadas e mantidas em execução, que ele mantém uma instância em cada região e ficamos protegido contra eventuais problemas que possamos ter.                                       
                                                                                  # temos que ter três instâncias em execução na porta 8000. 
  load_balancer {
    target_group_arn = aws_lb_target_group.alvo.arn
    container_name   = "producao"
    container_port   = 8000
  }
 
  network_configuration {                                                          # Essa configuração de rede vai nos garantir que a nossa aplicação seja sempre colocada na rede correta e que ela vai ser reconhecida pelo nosso load balancer.
    subnets = module.vpc.private_subnets                                           # Precisamos definir quais são as subnets e, no caso aqui, as subnets privadas que vamos utilizar. Como podemos fazer isso? Aqui no nosso arquivo de VPC, onde criamos a nossa VPC, através do módulo, especificamos quais são as subnets privadas, então vamos colocar uma referência aqui nesse arquivo de VPC para as nossas subnets privadas. Vamos lá. Para isso, vamos usar subnets = module.vpc.private_subnets.
    security_groups = [aws_security_group.privado.id]                              # Quando não especificamos nada, colocamos o id. Só um detalhe aqui que acaba sendo quase que uma pegadinha. Aqui quando fala security_groups ele põe um "s" no final, são os grupos de segurança, então podemos listar mais de um. Para isso, temos que colocar os colchetes para podemos listar um ou mais grupos de segurança.
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"                                                  # Aqui vai ser nosso prover a nossa capacidade, então no nosso caso vai ser o FARGATE. (FARGATE, FARGATE_SPOT ou EC2, são as três possibilidades de provedor de capacidade dentro do ECS.)
    weight = 1 #100/100                                                            # weight ou o peso do provedor de capacidade. No caso, queremos 100% da nossa capacidade dentro do FARGAT, então colocamos 1. weigth = 1. 
  }  

}