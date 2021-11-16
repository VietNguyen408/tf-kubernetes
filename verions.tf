terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0.1"
    }
    google = {
      source  = "hashicorp/google"
      version = ">=3.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }

  backend "gcs" {
    bucket = "tf-viet-testing"
    prefix = "tfstate-kubernetes"
  }
}
