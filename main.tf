provider "google" {
  project     = "delta-geode-378123"
  credentials = file("/Users/liwaa/Downloads/delta-geode-378123-8f94edbe2a6e.json")
  region      = "us-central1"
}

provider "kubernetes" {
  host                   = "https://35.202.183.17"
  config_path            = "~/.kube/config"
  config_context_cluster = "gke_delta-geode-378123_us-central1_autopilot-cluster-wideops-12"
  token                  = data.google_client_config.access_token.access_token
}

data "google_client_config" "access_token" {}


resource "google_container_cluster" "autopilot" {
  name                  = "autopilot-cluster-wideops-12"
  location              = "us-central1"
  remove_default_node_pool = true
  initial_node_count    = 1
}



resource "kubernetes_deployment" "wordpress" {
  metadata {
    name      = "wordpress"
    namespace = "default"
  }

  spec {
    replicas = 4

    selector {
      match_labels = {
        app = "wordpress"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = "wordpress:latest"

          port {
            container_port = 80
          }

          env {
            name  = "WORDPRESS_DB_HOST"
            value = "mongo-service"
          }

          env {
            name = "WORDPRESS_DB_USER"
            value_from {
              secret_key_ref {
                name = "mongo-secret"
                key  = "mongo-user"
              }
            }
          }

          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mongo-secret"
                key  = "mongo-password"
              }
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "mongodb" {
  metadata {
    name = "mongodb-service"
    namespace = "default"
  }
  spec {
    selector = {
      app = "mongodb"
    }
    port {
      name = "mongodb"
      port = 27017
      target_port = 27017
    }
  }
}



resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress"
  }

  spec {
    selector = {
      app = "wordpress"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_ingress" "wordpress" {
  metadata {
    name = "wordpress"
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    tls {
      secret_name = "wordpress-tls"
      hosts       = ["liwaadev.com"]
    }

    rule {
      host = "liwaadev.com"

      http {
        path {
          path = "/"
          backend {
            service_name = kubernetes_service.wordpress.metadata[0].name
            service_port = 80
          }
        }

        path {
          path = "/api"
          backend {
            service_name = kubernetes_service.wordpress.metadata[0].name
            service_port = 80
          }
        }

        path {
          path = "/mongodb"
          backend {
            service_name = kubernetes_service.mongodb.metadata[0].name
            service_port = 27017
          }
        }
      }
    }
  }
}


