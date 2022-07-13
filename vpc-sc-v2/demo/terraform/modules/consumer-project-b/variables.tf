variable "parent_folder" {}
variable "project_id" {}
variable "billing_account" {}
variable "region" {}
variable "create-user" {}
variable "vpc-network" {
    default = "consumer-project-b-vpc"
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
        "accesscontextmanager.googleapis.com"
    ]
  
}