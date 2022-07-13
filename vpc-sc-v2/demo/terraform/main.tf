provider "google" {
}

provider "google" {
    alias = "service"
    user_project_override = true
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Parent Folder
# ----------------------------------------------------------------------------------------------------------------------
resource "google_folder" "vpc-sc-folder" {
  display_name = var.demo_folder_name
  parent = "organizations/${var.org_id}"
}

# ----------------------------------------------------------------------------------------------------------------------
# Create & Configure Consumer Project A
# ----------------------------------------------------------------------------------------------------------------------
module "consumer-project-a" {
  source  = "./modules/consumer-project-a"
  parent_folder = google_folder.vpc-sc-folder.name
  project_id = var.consumer_project_a_id
  billing_account = var.billing_account
  region = var.default_region
  create-user = var.gcp_account_name

  depends_on = [
    google_folder.vpc-sc-folder
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create & Configure Consumer Project B
# ----------------------------------------------------------------------------------------------------------------------
module "consumer-project-b" {
  source  = "./modules/consumer-project-b"
  parent_folder = google_folder.vpc-sc-folder.name
  project_id = var.consumer_project_b_id
  billing_account = var.billing_account
  region = var.default_region
  create-user = var.gcp_account_name

  depends_on = [
    google_folder.vpc-sc-folder
  ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create & Configure Data Project
# ----------------------------------------------------------------------------------------------------------------------
module "data-project" {
  source  = "./modules/data-project"
  parent_folder = google_folder.vpc-sc-folder.name
  organization_id = var.org_id
  project_id = var.data_project_id
  billing_account = var.billing_account
  cloud_storage_bucket_name = var.cloud_storage_bucket_name
  region = var.default_region
  consumer-project-a-number = module.consumer-project-a.project_number
  consumer-project-b-number = module.consumer-project-b.project_number
  consumer-project-a-sa = module.consumer-project-a.compute_service_account
  consumer-project-b-sa = module.consumer-project-b.compute_service_account
  create-user = var.gcp_account_name

  providers = {
    google = google.service
  }
  
  depends_on = [
    module.consumer-project-a,
    module.consumer-project-b
  ]
}