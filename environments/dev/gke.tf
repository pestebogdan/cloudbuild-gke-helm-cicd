resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-cluster"
  location = "${var.region}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.project_id}-node-pool"
  location   = "${var.region}"
  cluster    = google_container_cluster.primary.name
  node_locations = [
    "${var.zone}",
  ]
  # node_count here actually means: "node_count PER ZONE", so by default, without the above node_locations, 3 nodes would be created with a node_count=1
  node_count = 1
  node_config {
    # Preemptible instances last only 24h but are a 3rd of the price. Good for testing.
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}