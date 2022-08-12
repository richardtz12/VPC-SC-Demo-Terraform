# ----------------------------------------------------------------------------------------------------------------------
# Create Parent Project
# ----------------------------------------------------------------------------------------------------------------------
# resource "google_project" "consumer_project_a" {
#   project_id      = "${substr(var.create-user,0,5)}-${var.project_id}-007"
#   name            = "Consumer Project A"
#   billing_account = var.billing_account
#   folder_id = var.parent_folder
#   auto_create_network = false
  
# }

# ----------------------------------------------------------------------------------------------------------------------
# Enable APIs
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service" "enable-services" {
  for_each = toset(var.services_to_enable)

  project = var.project_id
  service = each.value
  disable_on_destroy = false
}

resource "time_sleep" "wait_X_seconds" {
    create_duration = "60s"
    depends_on = [
      google_project_service.enable-services
    ]
}
