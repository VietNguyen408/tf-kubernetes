provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
    )
  }
}

resource "helm_release" "mysql" {
  name       = "my-mysql-release"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  namespace = "viet"

  values = [
    file("${path.module}/mysql-values.yaml")
  ]
  
}
