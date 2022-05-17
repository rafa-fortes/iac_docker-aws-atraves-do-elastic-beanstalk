module "homolog" {
    source = "../../infra"

    nome_repositorio = "homologacao"
    cargoIAM = "homologacao"
    ambiente = "homologacao"
}

output "IP_alb" {
  value = module.homolog.IP
}