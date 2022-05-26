variable consumer_project_a_id{
}

resource "google_project" "consumer_project_a" {
  project_id      = var.consumer_project_a_id
  name            = "consumer project a"
  billing_account = var.billing_account
  folder_id = google_folder.terraform_demo.name
  depends_on = [
      google_folder.terraform_demo
  ]
}

# Enable the Compute Engine API.
resource "google_project_service" "consumer_project_a_compute_service" {
  project = google_project.consumer_project_a.project_id
  service = "compute.googleapis.com"
}

resource "time_sleep" "wait_90_seconds_enable_compute_api_a" {
  depends_on = [google_project_service.consumer_project_a_compute_service]
  create_duration = "90s"
}

resource "google_compute_network" "vpc_network_a" {
  project                 = google_project.consumer_project_a.project_id
  name                    = "vpc-network-a"
  auto_create_subnetworks = false
  depends_on = [time_sleep.wait_90_seconds_enable_compute_api_a]
}

resource "google_compute_subnetwork" "vpc_a_subnetwork" {
  name          = "vpc-a-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  project = google_project.consumer_project_a.project_id
  network       = google_compute_network.vpc_network_a.self_link
  private_ip_google_access   = true 
  depends_on = [
    google_compute_network.vpc_network_a,
  ]
}

resource "google_compute_firewall" "vpc_network_a_allow_http_ssh_rdp_icmp" {
name = "vpc-network-a-allow-http-ssh-rdp-icmp"
network = google_compute_network.vpc_network_a.self_link
project = google_project.consumer_project_a.project_id
allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
    }
source_ranges = ["0.0.0.0/0"]
allow {
    protocol = "icmp"
    }
    depends_on = [
        google_compute_network.vpc_network_a
    ]
}

resource "google_service_account" "compute_service_account_a" {
  project = google_project.consumer_project_a.project_id
  account_id   = "compute-service-account-a"
  display_name = "Service Account A"
}

resource "google_compute_instance" "compute_engine_a" {
  project = google_project.consumer_project_a.project_id
  name         = "consumer-a-vm"
  machine_type = "n2-standard-4"
  zone         = "us-central1-a"
  shielded_instance_config {
      enable_secure_boot = true
  }
  depends_on = [
      google_compute_subnetwork.vpc_a_subnetwork,
      google_service_account.compute_service_account_a
  ]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network_a.self_link
    subnetwork = google_compute_subnetwork.vpc_a_subnetwork.self_link
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.compute_service_account_a.email
    scopes = ["cloud-platform"]
  }
}
