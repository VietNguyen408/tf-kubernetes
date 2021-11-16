provider "google" {
  project      = "syndeno"
  region       = var.region
  access_token = var.access_token
}

data "google_client_config" "provider" {}


data "google_container_cluster" "my_cluster" {
  name     = "syndeno"
  location = "europe-west4"
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
}

resource "kubernetes_namespace" "viet" {
  metadata {
    name = "viet"
  }
}

resource "kubernetes_deployment" "test" {
  metadata {
    name      = "pageview-deploy"
    namespace = kubernetes_namespace.viet.id
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
    name      = "pageview-svc"
    namespace = kubernetes_namespace.viet.id
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
