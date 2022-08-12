# ----------------------------------------------------------------------------------------------------------------------
# Create GCE Instance
# ----------------------------------------------------------------------------------------------------------------------
# Enable Service account
resource "google_service_account" "compute_service_account" {
  project = var.project_id
  account_id   = "compute-service-account"
  display_name = "Service Account"

  depends_on = [
    time_sleep.wait_X_seconds
  ]
}

# Create Instance
resource "google_compute_instance" "compute_engine" {
  project = var.project_id
  name         = "data-project-vm"
  machine_type = "n2-standard-4"
  zone         = "${var.region}-a"

  shielded_instance_config {
      enable_secure_boot = true
  }
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.vpc_subnetwork.self_link
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.compute_service_account.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
      google_compute_subnetwork.vpc_subnetwork,
      google_service_account.compute_service_account
  ]
}