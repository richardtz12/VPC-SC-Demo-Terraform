# ----------------------------------------------------------------------------------------------------------------------
# Create Parent Project
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project" "data_project" {
  project_id      = "${var.create-user}-${var.project_id}"
  name            = "data project"
  billing_account = var.billing_account
  folder_id = var.parent_folder
}

resource "time_sleep" "wait_y_seconds" {
    create_duration = "90s"
    depends_on = [
      google_project.data_project
    ]
}

# ----------------------------------------------------------------------------------------------------------------------
# Enable APIs
# ----------------------------------------------------------------------------------------------------------------------
resource "google_project_service" "enable-services" {
  for_each = toset(var.services_to_enable)

  project = google_project.data_project.id
  service = each.value
  disable_on_destroy = false
  depends_on = [
    time_sleep.wait_y_seconds
  ]
}

resource "time_sleep" "wait_X_seconds" {
    create_duration = "60s"
    depends_on = [
      google_project_service.enable-services
    ]
}