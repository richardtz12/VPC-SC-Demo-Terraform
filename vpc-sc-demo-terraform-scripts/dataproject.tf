variable data_project_id { 
}
variable cloud_storage_bucket_name {
}
variable create_default_access_policy {
}

resource "google_project" "data_project" {
  project_id      = var.data_project_id
  name            = "data project"
  billing_account = var.billing_account
  folder_id = google_folder.terraform_demo.name
  depends_on = [
      google_folder.terraform_demo
  ]
}

resource "google_storage_bucket" cloud_storage_bucket_name {
  name          = var.cloud_storage_bucket_name
  location      = "US"
  force_destroy = true
  project       = google_project.data_project.project_id
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "text" {
  name   = "text"
  content = "Some Sample Text"
  bucket = google_storage_bucket.cloud_storage_bucket_name.name
}

resource "google_project_iam_member" "data_viewer_a" {
  project = google_project.data_project.project_id
  role    = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.compute_service_account_a.email}"
  depends_on = [
      google_service_account.compute_service_account_a
  ]
}

resource "google_project_iam_member" "data_viewer_b" {
  project = google_project.data_project.project_id
  role    = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.compute_service_account_b.email}"
  depends_on = [
      google_service_account.compute_service_account_b
  ]
}

resource "google_project_iam_member" "data_viewer" {
  project = google_project.data_project.project_id
  role    = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.compute_service_account.email}"
  depends_on = [
      google_service_account.compute_service_account
  ]
}

# Enable the Compute Engine API.
resource "google_project_service" "data_project_compute_service" {
  project = google_project.data_project.project_id
  service = "compute.googleapis.com"
}

resource "time_sleep" "wait_90_seconds_enable_compute_api" {
  depends_on = [google_project_service.data_project_compute_service]
  create_duration = "90s"
}

resource "google_compute_network" "vpc_network" {
  project                 = google_project.data_project.project_id
  name                    = "vpc-network"
  auto_create_subnetworks = false
  depends_on = [time_sleep.wait_90_seconds_enable_compute_api]
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = "vpc-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  project = google_project.data_project.project_id
  network       = google_compute_network.vpc_network.self_link
  private_ip_google_access   = true 
  depends_on = [
    google_compute_network.vpc_network,
  ]
}

resource "google_compute_firewall" "vpc_network_allow_http_ssh_rdp_icmp" {
name = "vpc-network-allow-http-ssh-rdp-icmp"
network = google_compute_network.vpc_network.self_link
project = google_project.data_project.project_id
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

resource "google_service_account" "compute_service_account" {
  project = google_project.data_project.project_id
  account_id   = "compute-service-account"
  display_name = "Service Account"
}

resource "google_compute_instance" "compute_engine" {
  project = google_project.data_project.project_id
  name         = "data-project-vm"
  machine_type = "n2-standard-4"
  zone         = "us-central1-a"
  shielded_instance_config {
      enable_secure_boot = true
  }
  depends_on = [
      google_compute_subnetwork.vpc_subnetwork,
      google_service_account.compute_service_account
  ]

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
}

resource "google_project_service" "data_project_access_context_manager_service" {
  project = google_project.data_project.project_id
  service = "accesscontextmanager.googleapis.com"
}

resource "time_sleep" "wait_90_seconds_enable_acm_api" {
  depends_on = [google_project_service.data_project_access_context_manager_service]
  create_duration = "90s"
}

resource "google_access_context_manager_access_policy" "default" {
  count = var.create_default_access_policy ? 1 : 0
  provider = google.service
  parent = "organizations/${var.organization_id}"
  title  = "Default Org Access Policy"
}

resource "google_access_context_manager_access_policy" "vpc_sc_demo_policy" {
  provider = google.service
  parent = "organizations/${var.organization_id}"
  title  = "VPC SC demo policy"
  scopes = ["projects/${google_project.data_project.number}"]
  depends_on = [
    time_sleep.wait_90_seconds_enable_acm_api
  ]
}

resource "google_access_context_manager_service_perimeter" "service-perimeter" {
  provider = google.service
  parent = "accessPolicies/${google_access_context_manager_access_policy.vpc_sc_demo_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.vpc_sc_demo_policy.name}/servicePerimeters/restrict_storage"
  title  = "restrict_storage"
#   use_explicit_dry_run_spec = true
#   spec {
#     restricted_services = ["storage.googleapis.com"]
#     resources = ["projects/${google_project.data_project.number}"]
#     vpc_accessible_services {
#         enable_restriction = false        
#     }
#     ingress_policies {
#         ingress_from {
#             identities = ["user:${var.user_id}", "serviceAccount:${google_service_account.terraform_service_account.email}"]
#             sources {
#                 resource = "projects/${google_project.consumer_project_a.number}"
#             }
#         }
#         ingress_to { 
#             resources = [ "projects/${google_project.data_project.number}" ]
#             operations {
#                 service_name = "*"
#             } 
#         }
#     }
#   }
  status {
    restricted_services = ["storage.googleapis.com"]
    resources = ["projects/${google_project.data_project.number}"]
    vpc_accessible_services {
        enable_restriction = false        
    }
    ingress_policies {
        ingress_from {
            # identities = ["user:${var.user_id}", "serviceAccount:${google_service_account.terraform_service_account.email}"]
            sources {
                resource = "projects/${google_project.consumer_project_a.number}"
            }
            identity_type = "ANY_IDENTITY"
        }
        ingress_to { 
            resources = [ "projects/${google_project.data_project.number}" ]
            operations {
                service_name = "*"
            } 
        }
    }
  }
}
