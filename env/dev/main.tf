module "dev" {
    source = "../../infra"

    nome_repositorio = "desenvolvimento"
    cargoIAM = "desenvolvimento"
    ambiente = "desenvolvimento"
}

output "IP_alb" {
  value = module.dev.IP
}