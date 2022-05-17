# Criando nossa VPC (Cloud Virtual Privada ou Virtual Private Cloud) vai ajuda a separar aplicações com uma camada a mais de isolamento e protege os dados de aplicações, além de permitir uma proteção extra para a aplicação, ao utilizar redes privadas.
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "vpc-ecs"                                               # Esse VPC ECS, que é para o nosso elastic container service
  cidr = "10.0.0.0/16"                                           #cidr que é um jeito de expressarmos endereços de IP, por exemplo, o cidr da nossa VPC vai ser cird = "10.0.0.0/16", isso quer dizer que vamos do endereço #10.0.0.0, que é o endereço que não vai ser utilizado, vamos utilizar sempre o do #10.0.1.1 até o endereço 10.0.255.255. Temos todos esses endereços expressos aqui em uma única parte, isso é o cidr.

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]            # Uma lista de nomes ou IDs de zonas de disponibilidade na região.
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]         # Para as subnets privadas ele vai criar uma subnet para cada, private_subnets = ["10.0.1.0/24", “10.0.2.0/24”, “10.0.3.0/24”], só vai mudar esse último aqui, vai de 10.0.1.0/24 até 10.0.1.2/55, a mesma coisa para 10.0.2.0/24 e para 10.0.3.0/24.
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]   # Uma lista de sub-redes públicas dentro da VPC

  enable_nat_gateway = true                                               # Vamos criar um enable_nat_gateway = true para as nossas subnets privadas porque as nossas subnets privadas não vão conseguir acessar a internet para mandar de volta as requisições.

}
