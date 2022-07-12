variable "organization_id" {
  type        = string
  description = "organization id required"
}
variable "billing_account" {
 type        = string
 description = "billing account required"
}
variable "demo_folder_name" {
 type        = string
 description = "unique name of demo folder to be created"
}
variable "data_project_id" {
 type        = string
 description = "globally unique id of data project to be created"
}
variable "consumer_project_a_id" {
 type        = string
 description = "globally unique id of consumer project a to be created"
}
variable "consumer_project_b_id" {
 type        = string
 description = "globally unique id of consumer project b to be created"
}
variable "cloud_storage_bucket_name" {
 type        = string
 description = "globally unique name of cloud storage bucket to be created"
}
variable "create_default_access_policy" {
 type        = bool
 default     = false
 description = "Whether a default access policy needs to be created for the organization. If one already exists, this should be set to false."
}