terraform {
  backend "gcs" {
    bucket = "cicd-313009-tfstate"
    prefix = "env/dev"
  }
}