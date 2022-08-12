# ----------------------------------------------------------------------------------------------------------------------
# Create GCE Instance
# ----------------------------------------------------------------------------------------------------------------------
# Configure default policy
resource "google_access_context_manager_access_policy" "vpc_sc_demo_policy" {
    provider = google
    parent = "organizations/${var.organization_id}"
    title  = "VPC SC demo policy"
    scopes = ["projects/606895948707"]

    depends_on = [
        time_sleep.wait_X_seconds
    ]
}

resource "google_access_context_manager_service_perimeter" "service-perimeter" {
    provider = google
    parent = "accessPolicies/${google_access_context_manager_access_policy.vpc_sc_demo_policy.name}"
    name   = "accessPolicies/${google_access_context_manager_access_policy.vpc_sc_demo_policy.name}/servicePerimeters/restrict_storage"
    title  = "restrict_storage"

    status {
        restricted_services = ["storage.googleapis.com"]
        resources = ["projects/606895948707"]
        vpc_accessible_services {
            enable_restriction = false        
        }

        ingress_policies {
            ingress_from {
                sources {
                    resource = "projects/${var.consumer-project-a-number}"
                }
                identity_type = "ANY_IDENTITY"
            }
            ingress_to { 
                resources = [ "projects/606895948707" ]
                operations {
                    service_name = "*"
                } 
            }
        }

        ingress_policies {
            ingress_from {
                sources {
                    resource = "projects/407882540211"
                }
                identity_type = "ANY_IDENTITY"
            }
            ingress_to { 
                resources = [ "projects/606895948707" ]
                operations {
                    service_name = "*"
                } 
            }
        }

        ingress_policies {
          ingress_from {
            sources {
                    access_level = "*"
                }
            identities = ["user:${var.current_user}"]
          }
          ingress_to { 
                resources = [ "projects/606895948707" ]
                operations {
                    service_name = "*"
                } 
            }
        }
    }

    depends_on = [
        google_access_context_manager_access_policy.vpc_sc_demo_policy
    ]
}