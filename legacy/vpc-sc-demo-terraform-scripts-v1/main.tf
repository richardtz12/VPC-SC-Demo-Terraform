variable organization_id {
}
variable billing_account{    
}
variable demo_folder_name {
}

resource "google_folder" "terraform_demo" {
  display_name = var.demo_folder_name
  parent = "organizations/${var.organization_id}"
}

resource "google_service_account" "terraform_service_account" {
  project = google_project.data_project.project_id
  account_id   = "terraform-service-account"
  display_name = "Terraform Service Account"
}

//Access Context Manager Admin
//Editor
//Organization Administrator
//Owner
//Project IAM Admin
//Service Usage Admin

resource "google_organization_iam_member" "access_context_manager_admin" {
  org_id  = var.organization_id
  role    = "roles/accesscontextmanager.policyAdmin"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}

resource "google_organization_iam_member" "editor" {
  org_id  = var.organization_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}

resource "google_organization_iam_member" "organization_administrator" {
  org_id  = var.organization_id
  role    = "roles/resourcemanager.organizationAdmin"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}

resource "google_organization_iam_member" "organization_viewer" {
  org_id  = var.organization_id
  role    = "roles/resourcemanager.organizationViewer"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}

resource "google_organization_iam_member" "organization_role_viewer" {
  org_id  = var.organization_id
  role    = "roles/iam.organizationRoleViewer"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}

resource "google_organization_iam_member" "owner" {
  org_id  = var.organization_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}

resource "google_organization_iam_member" "project_iam_admin" {
  org_id  = var.organization_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}

resource "google_organization_iam_member" "service_usage_admin" {
  org_id  = var.organization_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"
}
