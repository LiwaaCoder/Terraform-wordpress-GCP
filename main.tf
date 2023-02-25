provider "google" {
  project     = "wideops-challlenge-dev"
  credentials = file("/Users/liwaa/Downloads/wideops-challlenge-dev-39f036c669e3.json")
  region      = "us-central1"
}


resource "google_sql_database_instance" "wordpress" {
  name             = "wordpress"
  database_version = "MYSQL_8_0"
  region           = "us-central1"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "wordpress" {
  name     = "wordpress"
  instance = google_sql_database_instance.wordpress.name

  charset    = "utf8mb4"
  collation  = "utf8mb4_general_ci"

  depends_on = [google_sql_database_instance.wordpress]
}



resource "random_string" "username" {
  length  = 10
  special = false
}

resource "random_password" "password" {
  length  = 16
  special = true
}

output "db_name" {
  value = google_sql_database.wordpress.name
}

output "db_username" {
  value = random_string.username.result
}

output "db_password" {

  value = random_password.password.result
  sensitive = true
}



resource "google_compute_network" "vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc-subnet" {
  name          = "my-vpc-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc.self_link
}


provider "kubernetes" {
  config_path = "~/.kube/config"
}



resource "google_container_cluster" "wordpress" {
  name               = "wordpress"
  location           = "us-central1"
  initial_node_count = 2
  network            = google_compute_network.vpc.name
  subnetwork         = google_compute_subnetwork.vpc-subnet.self_link # added subnetwork

  node_config {
    machine_type = "n1-standard-1"
    disk_size_gb = 10

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}






resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
  }

  spec {
    replicas = 2

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
          image = "wordpress:latest"
          name  = "wordpress"

          env {
            name  = "WORDPRESS_DB_HOST"
            value = google_sql_database_instance.wordpress.connection_name

          }

          env {
            name  = "WORDPRESS_DB_USER"
            value = "root"
          }

          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = "sqlsql123"
          }

          env {
            name  = "WORDPRESS_DB_NAME"
            value = google_sql_database.wordpress.name
          }

          port {
            container_port = 80
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
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = kubernetes_service.wordpress.metadata[0].name
            service_port = 80
          }
          path = "/"
        }
      }
    }
  }
}

