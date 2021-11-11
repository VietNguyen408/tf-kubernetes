terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
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
