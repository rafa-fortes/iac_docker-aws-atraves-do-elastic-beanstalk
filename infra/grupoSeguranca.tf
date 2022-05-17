# Esse grupo vai está na nossa rede público, sendo assim ele tem que permitir que as requisições cheguem e sejam processadas pelo load-balancer que vai estar na rede pública.

# Grupo de segurança da rede pública feito para o load- balancer, no nosso caso vai ser um load-balancer de aplicação, é o application load-balancer ou um "alb"
resource "aws_security_group" "alb" {
  name        = "alb_ECS"
  vpc_id      = module.vpc.vpc_id                       # O ID da VPC, para conseguirmos esse Id eu vou pegar lá no nosso arquivo de VPC. O normal seria criar através de um recurso só que teria muito código e veríamos que os módulos servem para nos ajudar nesses momentos que temos que escrever muita coisa. Criamos a VPC através de um módulo, por isso não podemos usar o recurso, vamos usar o próprio módulo para conseguir essa informação.
  }

# Regras de entrada do grupo de segurança "alb"
  resource "aws_security_group_rule" "tcp_alb" {         # O nome dessa regra vai ser "tcp_alb" para o nosso application load balancer liberar todas as portas tcp.
  type              = "ingress"
  from_port         = 8000                               # Nossa aplicação usa a porta 8000, por isso temos que permitir a entrada de qualquer coisa que chegue na porta
  to_port           = 8000                               # até a porta 8000, a nossa aplicação só usa uma porta não precisamos liberar várias delas, podemos liberar uma só.
  protocol          = "tcp"                              # O protocolo pode ser protocol = “tcp”, que é um protocolo de rede para fazer a nossa comunicação. Obs: protocolo das conexões SSH é o TCP.
  cidr_blocks       = ["0.0.0.0/0"]                      # No cidr blocks vamos precisar colocar de qual IP que pode vir as requisições, no nosso caso queremos receber a requisição de qualquer IP da internet, vamos colocar o IP cidr_blocks = [“0.0.0.0/0”]. (se colocarmos o barra 32 nós travamos nesse número, se colocarmos o barra 24 podemos ir de 0000 até 000255 e assim por diante. Cada vez que vamos baixando oito números aqui vamos liberando um número desse para ir de 0 até 255. Quando colocamos 0000/0 estamos podendo do que colocamos de todos os 0 até o 255.255.255.255, ou seja, qualquer local na internet.)
  security_group_id = aws_security_group.alb.id
}

# Regras de saída do grupo de segurança.
  resource "aws_security_group_rule" "tcp_alb" {         
  type              = "engress"
  from_port         = 0                                  # Queremos que saia tudo da nossa aplicação, a nossa aplicação pode responder para qualquer porta e para qualquer um, da porta 0 até a porta 0, assim não definimos um limite de portas, pode ir de qualquer uma até qualquer um.                  
  to_port           = 0                               
  protocol          = "-1"                               # O protocolo queremos que ela possa responder para qualquer protocolo, por isso a AWS aceita protocol = “-1” como protocolo para liberarmos para qualquer um deles.         
  cidr_blocks       = ["0.0.0.0/0"]                      # Queremos responder para qualquer um na internet, por isso mantemos o cidr_blocks igual o da entrada.                
  security_group_id = aws_security_group.alb.id
}

# Acabamos de criar e configurar o nosso grupo de segurança
# para permitir a entrada para o nosso load balancer na porta 8000 com
# o protocolo TCP e saída para qualquer porta com qualquer protocolo
# para qualquer máquina de internet.


# Grupo para a rede privada, assim vamos conseguir nos comunicar entre a nossa rede pública e a rede privada, o que possibilita o uso do load balancer e protege a nossa aplicação.
resource "aws_security_group" "privado" {
  name        = "privado_ECS"
  vpc_id      = module.vpc.vpc_id
}                       


# Regras de entrada do grupo de segurança "privado"
  resource "aws_security_group_rule" "entrada_ECS" {    # Lembre-se que o no ECS vai executar na nossa rede privada, tudo o que entrar na rede privada tem que passar por esse grupo de segurança, por esse security group.      
  type              = "ingress"
  from_port         = 0                                  #Essas requisições vão vir do load balancer, pode ser qualquer protocolo.                        
  to_port           = 0                               
  protocol          = "-1"                               # Criamos uma entrada que permite vir de qualquer porta para qualquer porta com qualquer protocolo, isso inclui HTTP, HTTPS, TCP, UDP e assim por diante.
  source_security_group_id = aws_security_group.alb.id   # Só que limitamos de onde essas requisições podem vir, elas só podem vir de recursos da nossa rede pública. Se eu fizer uma requisição do meu computador pessoal para a minha rede privada essa requisição vai ser travada, se eu fizer um requisição para o nosso load balancer e o nosso load balancer passar essa requisição para dentro da nossa rede privada aí é válido, passa tranquilo.
  security_group_id = aws_security_group.privado.id
}

# Regras de saída do grupo de segurança "privado"
  resource "aws_security_group_rule" "saida_ECS" {         
  type              = "engress"
  from_port         = 0                                  # Queremos que saia tudo da nossa aplicação, a nossa aplicação pode responder para qualquer porta e para qualquer um, da porta 0 até a porta 0, assim não definimos um limite de portas, pode ir de qualquer uma até qualquer um.                  
  to_port           = 0                               
  protocol          = "-1"                               # O protocolo queremos que ela possa responder para qualquer protocolo, por isso a AWS aceita protocol = “-1” como protocolo para liberarmos para qualquer um deles.         
  cidr_blocks       = ["0.0.0.0/0"]                      # Queremos responder para qualquer um na internet.   (0.0.0.0 - 255.255.255.255)           
  security_group_id = aws_security_group.privado.id
}

# Configuramos nosso grupo de segurança que está na nossa rede privada possibilitando recebermos as nossas
# requisições e vamos começar a respondê-las. Porém essas requisições
# só podem vir da nossa rede pública, do grupo de segurança que é a
# nossa rede pública dando uma camada extra de proteção para a nossa aplicação.
