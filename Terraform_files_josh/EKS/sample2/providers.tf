provider "aws" {
  region = "us-east-1"
}

terraform {

  required_version = ">= 1.2.0"
  required_providers {
    kubernetes = {
        source = "gavinbunney/kubectl"
        version = ">= 1.19.0"
    }
    helm = {
        source = "hashicorp/helm"
        version = ">= 2.6.0"
    }
  }

}