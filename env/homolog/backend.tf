terraform {
  backend "s3" {
    bucket = "terraform-state-rafaelfortes"
    key    = "homolog/terraform.tfstate"
    region = "us-west-2"
  }
}