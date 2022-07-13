# ----------------------------------------------------------------------------------------------------------------------
# Create VPC
# ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_network" "vpc_network" {
  project                 = google_project.consumer_project_a.project_id
  name                    = var.vpc-network
  auto_create_subnetworks = false
}

# Create Subnets
resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = "vpc-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  project       = google_project.consumer_project_a.project_id
  network       = google_compute_network.vpc_network.self_link
  private_ip_google_access   = true 
  depends_on = [
    google_compute_network.vpc_network,
  ]
}

# Enable Router
resource "google_compute_router" "primary" {
  name    = "${google_compute_subnetwork.vpc_subnetwork.region}-router"
  region  = "${google_compute_subnetwork.vpc_subnetwork.region}"
  network = google_compute_network.vpc_network.id
  project                 = google_project.consumer_project_a.project_id

  bgp {
    asn = 64514
  }

  depends_on = [
    google_compute_subnetwork.vpc_subnetwork
    ]
}

# Enable Nat
resource "google_compute_router_nat" "nat" {
  name                               = "${var.region}-nat"
  router                             = google_compute_router.primary.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                 = google_project.consumer_project_a.project_id

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  depends_on = [
    google_compute_router.primary
    ]
}

# Enable RDP Access
resource "google_compute_firewall" "vpc_network_allow_http_ssh_rdp_icmp" {
    name            = "vpc-network-allow-http-ssh-rdp-icmp"
    network         = google_compute_network.vpc_network.self_link
    project         = google_project.consumer_project_a.project_id

    allow {
        protocol = "tcp"
        ports    = ["22", "80", "3389"]
        }

    source_ranges = ["0.0.0.0/0"]

    allow {
        protocol = "icmp"
        }
    depends_on = [
        google_compute_network.vpc_network
    ]
}