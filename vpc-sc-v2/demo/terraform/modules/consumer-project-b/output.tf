output "project_number" {
    value = google_project.consumer_project_b.number
}

output "compute_service_account" {
    value = google_service_account.compute_service_account.email
}