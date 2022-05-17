terraform {
  backend "s3" {
    bucket = "terraform-state-rafaelfortes"
    key    = "dev/terraform.tfstate"
    region = "us-west-2"
  }
}