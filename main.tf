provider "google" {
  project = "delta-geode-378123"
  credentials = file("/Users/liwaa/Downloads/delta-geode-378123-8f94edbe2a6e.json")
  region = "us-central1"
}


  data "google_client_config" "access_token" {}


provider "kubernetes" {
  host                   = "https://35.202.183.17"
  config_path = "~/.kube/config"
  config_context_cluster = "gke_delta-geode-378123_us-central1_autopilot-cluster-wideops-12"
  token                  = data.google_client_config.access_token.access_token
}



resource "google_container_cluster" "autopilot" {
  name     = "autopilot-cluster-wideops-12"
  location = "us-central1"
  remove_default_node_pool = true
  initial_node_count = 1
}


resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
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
          name = "wordpress"
          image = "wordpress:latest"
          port{
            container_port = 80
          }
          env {
            name = "WORDPRESS_DB_HOST"
            value = "mysql-service"
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key = "password"
              }
            }
          }
        }
      }
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
      name = "http"
      port = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}


resource "kubernetes_horizontal_pod_autoscaler" "wordpress" {
  metadata {
    name = "wordpress"
  }
  spec {
    max_replicas = 10
    min_replicas = 2
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment.wordpress.metadata[0].name
    }
    target_cpu_utilization_percentage = 50
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
      hosts = ["liwaadev.com"]
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
      }
    }
  }
}


