# ----------------------------------------------------------------------------------------------------------------------
# Create Storage Bucket
# ----------------------------------------------------------------------------------------------------------------------
resource "google_storage_bucket" cloud_storage_bucket_name {
  name          = format("%s%s", var.project_id, var.cloud_storage_bucket_name) 
  location      = "US"
  force_destroy = true
  project       = google_project.data_project.id

  uniform_bucket_level_access = true

  depends_on = [
    time_sleep.wait_X_seconds
  ]
}


# Create & Upload sample GCS Content
resource "google_storage_bucket_object" "text" {
  name   = "text"
  content = "Some Sample Text"
  bucket = google_storage_bucket.cloud_storage_bucket_name.name

  depends_on = [
    google_storage_bucket.cloud_storage_bucket_name
  ]
}


# Create Multi-project Access
resource "google_project_iam_member" "data_viewer_a" {
  project = google_project.data_project.id
  role    = "roles/storage.admin"
  member = "serviceAccount:${var.consumer-project-a-sa}"
  
  depends_on = [
    google_project_iam_member.data_viewer
  ]
}

resource "google_project_iam_member" "data_viewer_b" {
  project = google_project.data_project.id
  role    = "roles/storage.admin"
  member = "serviceAccount:${var.consumer-project-b-sa}"

  depends_on = [
    google_project_iam_member.data_viewer
  ]
}

resource "google_project_iam_member" "data_viewer" {
  project = google_project.data_project.id
  role    = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.compute_service_account.email}"
  
  depends_on = [
      google_service_account.compute_service_account
  ]
}