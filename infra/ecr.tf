# Criando nosso repositório da AWS chamado de ECR que é o Elastic Container Repository.
# Para que essa imagem fique disponível em um repositório, assim não precisamos nos preocupar com a disponibilidade e nem em perdermos essa imagem. 
resource "aws_ecr_repository" "repositorio" {              # Esse é o nome lógico
  name                 = var.nome_repositorio              # Esse é o nome na AWS, mas para esse nome eu vou criar aqui ao invés de um nome fixo, vamos usar uma variável name = var.nome_repositorio.
}





