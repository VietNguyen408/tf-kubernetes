variable "access_token"{
  type = string 
}

provider "google" {
  project = "syndeno"
  region  = "europe-west4"
  access_token = var.access_token
}
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=3.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

data "google_service_account_access_token" "my_kubernetes_sa" {
  target_service_account = "{{service_account}}"
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "3600s"
}

data "google_container_cluster" "my_cluster" {
  name     = "syndeno"
  location = "europe-west4"
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_service_account_access_token.my_kubernetes_sa.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
}

resource "kubernetes_deployment" "test" {
  metadata {
    name = "pageview-deploy"
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        tier = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          tier = "frontend"
        }
      }
      spec {
        container {
          image = "vietnguyen408/pageview:v0.0.1"
          name  = "pageview"
        }
      }
    }
  }
}

resource "kubernetes_service" "test" {
  metadata {
    name = "pageview-svc"
  }
  spec {
    selector = {
      tier = "frontend"
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 8084
    }
  }
}
