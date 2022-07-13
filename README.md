# GCP VPC Service Controls

Requirement: **GCP PROJECT INTO WHICH TO DEPLOY**

# Tool Setup Guide

[Tool Install Guide](tools/ReadMe.md)

# Environment Setup
* Install tools
* Run the following commands to login to gcloud:
```
gcloud auth login
gcloud auth application-default login
```

This will setup your permissions for terraform to run.

# Deploy guide
```
cd terraform
terraform init
terraform plan
terraform apply
```

## Required Variables:
- **org_id** - Organization ID
- **billing_account** - Billing Account to be assigned to projects. You must have **billing user** permissions on that account. [More Details Can Be Found Here](https://cloud.google.com/billing/docs/how-to/manage-billing-account)