# Cargo = role
resource "aws_iam_role" "cargo" {
  name = "${var.cargoIAM}_cargo"                    // O nome desse cargo pode variar de acordo com o ambiente que tivermos, então vamos colocá-lo em forma de uma variável, e nesse caso aqui vamos fazer o seguinte: vamos colocar o name = "${var.cargoIAM}". E só para termos certeza que é um cargo [ININTELIGÍVEL] no console AWS, eu vou colocar na frente name = "${var.cargoIAM}_cargo". 

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ec2.amazonaws.com", "ecs-task.amazonaws.com"] //Quais serviços podem utilizar? Nesse caso vou colocar o EC2 vai poder utilizar esse cargo e o ECS vai poder utilizar esse cargo. 
        }
      },
    ]
  })

}

# A próxima parte são as permissões em si que esse cargo vai ter e,
# nesse caso, não vamos precisar de uma grande quantidade de permissões, 
# mas vamos precisar das permissões para acessar o ECR, que é o nosso repositório com a nossa imagem do
# Docker, e de logs, para podermos salvar alguns logs da nossa aplicação
# para podermos resolver casos de erro que vamos ter.

#Criando as politicas do nosso cargo.

resource "aws_iam_role_policy" "ecs_ecr" {      # Ela permite que o ECS acesse o ECR
  name = "ecs_ecr"
  role = aws_iam_role.cargo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",           # Obtém um token de autorização. Esse token funciona como credenciais de autorização do IAM e pode ser utilizado para acessar os recursos do Amazon ECR.
          "ecr:BatchCheckLayerAvailability",     # Verifica a existência de uma ou mais layers de imagens no repositório.  
          "ecr:GetDownloadUrlForLayer",          # Retorna um link do S3 (onde a Amazon guarda os arquivos) que direciona para os layers da imagem. 
          "ecr:BatchGetImage",                   # Obtém informações detalhadas de uma imagem em específico e em seguida retorna o manifesto da imagem com suas configurações.
          "logs:CreateLogStream",                # Cria os logs.
          "logs:PutLogEvents"                    # Coloca os eventos nesses logs, para podemos ver se deu algum tipo de erro na aplicação. 
        ] 
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Por fim, vamos criar o perfil que vai utilizar esse cargo na nossa aplicação.

resource "aws_iam_instance_profile" "perfil" {
  name = "${var.cargoIAM}_perfil"
  role = aws_iam_role.cargo.name
}