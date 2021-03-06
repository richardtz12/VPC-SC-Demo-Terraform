variable "demo_folder_name" {
 type        = string
 description = "unique name of demo folder to be created"
 default = "vpc-sc-demo"
}
variable "data_project_id" {
 type        = string
 description = "globally unique id of data project to be created"
 default = "data-project"
}
variable "consumer_project_a_id" {
 type        = string
 description = "globally unique id of consumer project a to be created"
 default = "consumer-a-project"
}
variable "consumer_project_b_id" {
 type        = string
 description = "globally unique id of consumer project b to be created"
 default = "consumer-b-project"
}
variable "cloud_storage_bucket_name" {
 type        = string
 description = "globally unique name of cloud storage bucket to be created"
 default = "sample-content-bucket"
}
variable "create_default_access_policy" {
 type        = bool
 default     = false
 description = "Whether a default access policy needs to be created for the organization. If one already exists, this should be set to false."
}

variable "default_region" {
  type = string
  description = "Default region to deploy"
  default = "us-central1"
  
}

# ----------------------------------------------------------------------------------------------------------------------
# Optional Vars
# ----------------------------------------------------------------------------------------------------------------------
variable "project_name" {
 type        = string
 description = "project name in which demo deploy"
}
variable "project_number" {
 type        = string
 description = "project number in which demo deploy"
}
variable "gcp_account_name" {
  description = "user performing the demo"
}
variable "deployment_service_account_name" {
 description = "Cloudbuild_Service_account having permission to deploy terraform resources"
}
variable "org_id" {
  type        = string
  description = "organization id required"
}
variable "billing_account" {
 type        = string
 description = "billing account required"
}