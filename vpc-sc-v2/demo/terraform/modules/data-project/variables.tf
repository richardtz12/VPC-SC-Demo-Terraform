variable "parent_folder" {}
variable "organization_id" {}
variable "project_id" {}
variable "billing_account" {}
variable "cloud_storage_bucket_name" {}
variable "consumer-project-a-sa" {}
variable "consumer-project-b-sa" {}
variable "consumer-project-a-number" {}
variable "consumer-project-b-number" {}
variable "region" {}
variable "create-user" {}
variable "create_default_access_policy" {
    default = 1
}
variable "vpc-network" {
    default = "data-project-vpc"
}

# Service to enable
variable "services_to_enable" {
    description = "List of GCP Services to enable"
    type    = list(string)
    default =  [
        "compute.googleapis.com",
        "monitoring.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "iam.googleapis.com",
        "servicenetworking.googleapis.com",
        "storage.googleapis.com",
        "accesscontextmanager.googleapis.com",
        "serviceusage.googleapis.com"
    ]
  
}