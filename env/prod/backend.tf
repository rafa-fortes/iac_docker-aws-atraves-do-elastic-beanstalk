terraform {
  backend "s3" {
    bucket = "terraform-state-rafaelfortes"
    key    = "prod/terraform.tfstate"
    region = "us-west-2"
  }
}
