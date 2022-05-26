provider "google" {
}

provider "google" {
    alias = "service"
    impersonate_service_account = google_service_account.terraform_service_account.email
}