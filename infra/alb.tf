
# Uma das vantagens dos containers é que podemos escalar a nossa aplicação de forma muito rápida,
# porém caso tenhamos mais de uma instância em execução com a nossa aplicação, 
# precisamos distribuir a carga entre eles. E esse é o trabalho do load balancer, 
# no nosso caso vamos usar três zonas de disponibilidade, assim ficamos protegidos contra 
# problemas físicos no Data Centers, como falta luz, queda de conexão, entre outros.


#Criando nosso LoadBalancer
resource "aws_lb" "alb" {
  name               = "ECS-Django"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets # As subnets são opcionais, mas elas vão falar aonde devemos colocar o nosso load balancer, para ele não ficar solto na nossa VPC temos que escolher se ele vai ficar na pública ou na privada. Vamos usar aqui a subnet pública, podemos descrever manualmente as nossas subnets públicas, como podemos utilizar o nosso módulo da VPC. subnets = [module.vpc.], agora aqui vamos precisar de uma forma de descrever as nossas subnets públicas, assim vamos travar o nosso load balancer na subnet pública.
}


# Entrada do LoadBalancer (listener)               # A nossa aplicação responde a protocolo http, então vamos colocar resource "aws_lb_listener" "http" como nome lógico para sabermos qual é o tipo de protocolo logo de cara, só batendo o olho no recurso, qual o protocolo que ele recebe.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "8000"                       # A porta que vamos estar ouvindo é a mesma porta da nossa aplicação, é a porta port = “8000”.
  protocol          = "HTTP"                       # O nosso protocolo é o HTTP

  default_action {
    type             = "forward"                     # Passar para frente. 
    target_group_arn = aws_lb_target_group.alvo.arn  # Para Onde as requisições devem ser enviadas. sse grupo é chamado de target group ou de grupo alvo.
  }
}

# TARGET GROUP

# Agora para o Load Balancer ficar totalmente operacional, 
# vamos criar o target grupo para onde as requisições devem ser enviadas.
# No nosso caso como a aplicação vai está no ECS, precisamos que o grupo alvo seja 
# uma rede completa e não apenas uma instância. 
# Sendo assim, vamos precisar de um novo campo o target type.
# Com ele podemos especificar que tipo de alvo vamos querer tendo opções que podem ser
# IDs das instâncias ou endereços de IP. Por conta do ECS não podemos
# usar os IDs, logo temos que usar os endereços de IP.


# Criando nosso target group. Por conta do ECS não podemos usar os IDs, logo temos que usar os endereços de IP.

resource "aws_lb_target_group" "alvo" {
  name        = "ECS-Django"                       # o nome da AWS eu vou colocar o mesmo nome do nosso load balancer que é name = "ECS-Django". Como eles aparecem em locais separados e eles aparecem vinculados mesmo estando em locais separados é interessante darmos o mesmo nome para os dois.
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}


# Temos que especificar o target_type se quisermos alterar o tipo
# de grupo alvo. O padrão é por instância que é onde ele vai pegar os IDs
# das instâncias. Sempre que criamos uma instância, por exemplo, na
# EC2 ele cria um ID para essa instância, é um número único, grande
# que ele acaba criando que só essa instância tem esse ID.


# E sempre que você destrói uma instância e cria outra ele cria com outro ID,
# esse ID depende de características da instância, data e hora que está sendo criada 
# e de algumas outras coisas definidas pela AWS para fazer com que esse número seja único para essa instância.

# No nosso caso estamos indo pelo endereço de IP, isso ocorre
# por causa no ECS. O ECS só funciona se tivermos um load balancer que
# seja via endereços de IP, já que ele não se baseia em instâncias da EC2.
# Apesar de ele criar essas instâncias, elas estão meio que por baixo dos
# panos e ela não mostra as instâncias para nós e nem para o load
# balancer, por isso temos que ser por IP.


# Criando nossa saída para essa aplicação, para o nosso load balancer.

output "IP" {
  value = aws_lb.alb.dns_name
}

# O DNS name vai ser interessante colocarmos como uma saída porque através dele temos o endereço (url) que podemos
# colocar no nosso navegador, porque uma vez que colocamos na nossa aplicação podemos acessar sem ter que
# entrar no console da AWS, buscando pelos load balancers, achar qual load balancer que é da nossa aplicação só para achar o endereço que
# temos que utilizar para essa aplicação em si.

