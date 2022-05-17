module "prod" {
    source = "../../infra"

    nome_repositorio = "producao"
    cargoIAM = "producao"
    ambiente = "producao"
}

# cadastrarmos essa saída no nosso módulo de produção.
# para sair o endereço IP dele quando executarmos o Terraform Apply e criá-lo na nossa infraestrutura.
output "IP_alb" {
  value = module.prod.IP
}

# Essa output vai puxar do módulo de produção que criamos que é de onde é a saída desse módulo.
# value = module.prod.IP. O value é o valor que vai ser colocado na saída. Podemos colocar aqui, por
# exemplo, podemos colocar aqui 0 e sempre executarmos o comando de 
# Terraform Apply vai ser uma valor 0 no terminal, não é muito útil, mas funciona.
# Nós também podemos colocar alguma coisa um pouco mais útil como, por exemplo, o endereço de IP do nosso load balancer.