provider "google" {
  project = "delta-geode-378123"
  credentials = file("/Users/liwaa/Downloads/delta-geode-378123-8f94edbe2a6e.json")

  region  = "us-central1"
  zone    = "us-central1-a"
}

resource "google_container_cluster" "cluster" {
  name     = "wideops-cluster"
  location = "us-central1"


  node_pool {
    name       = "my-node-pool"
    autoscaling {
      min_node_count = 2
      max_node_count = 10
    }
    node_config {
      machine_type = "e2-medium"
      disk_size_gb = 100
      disk_type    = "pd-standard"
    }
  }
}


output "kubeconfig" {
  value = google_container_cluster.cluster.master_auth[0].client_certificate
}

output "cluster_ca_certificate" {
  value = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
}
