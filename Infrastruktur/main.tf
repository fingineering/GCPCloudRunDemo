terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.31.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = var.project_name
  region = var.location
}


/*
 * Cloud Run Service Account
 * =========================
 *
 * A Cloud Run Job will run under a service account, to have an individual 
 * identity. It is recommended to use one service account per service to have
 * the most control over the permissions.
 * 
 * Using RBAC can make resource access very convienient, while being granular.
 */
resource "google_service_account" "cloud_run_demo_sa" {
  project      = var.project_name
  account_id   = "cloudrundemosa"
  description  = "Running Cloud Run Scheduled Job to update data in BigQuery under this account"
  display_name = "Cloud Run Demo Service Account"
}
# Service account for scheduler to call the function
resource "google_service_account" "cloud_shedule_caller" {
  project = var.project_name
  account_id = "cloudscheduler"
  description = "A service account to run the scheduler under an invoke the cloud run service"
  display_name = "Cloud Scheduler Demo User"
}

/*
 * Container Registry
 * ==================
 * 
 * Google Cloud Run uses a Docker Container as the compute layer. For a custom
 * application to be run on Cloud Run, a custom container needs to hosted. 
 * In this example the container is hosted in Google Container Registry, it is 
 * as well possible to use any other container registry like DockerHub oder ACR
 */
resource "google_artifact_registry_repository" "container_demo_repo" {
  location      = var.location
  project       = var.project_name
  repository_id = var.container_name
  description   = "Demo docker repository"
  format        = "DOCKER"
}

// create the url of a container in the registry, by name of container
data "google_container_registry_image" "demo_container" {
  name    = var.container_name
  project = var.project_name
}


/* 
 * Cloud Run Job
 * =============
 *
 * The Cloud Run Job will be a Cloud Run service, which is triggered by a schedule
 * The schedule itself is defined below and references the Cloud Run service.
 *
 * Within the service the container image to use is defined. To implement CI/CD
 * Cloud Build will be used to build the image from a dockerfile and update it
 * in the Google Container Registry
 *
 * There need some IAM binding to be made:
 * 1. Cloud Shedules must be allowed to ivoke the cloud run service
 * 2. Cloud Build must be allowed to edit the cloud run service
 */
resource "google_cloud_run_service" "cloud_run_demo" {
  project  = var.project_name
  name     = var.RunJobName
  location = var.location

  template {
    spec {
      containers {
        image = "europe-west3-docker.pkg.dev/${var.project_name}/${var.container_name}/${var.container_name}:latest"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

}
# allow shedule to run the cloud run service
resource "google_cloud_run_service_iam_binding" "invoker" {
  location = var.location
  project = var.project_name
  service = google_cloud_run_service.cloud_run_demo.name
  role = "roles/run.invoker"
  members = [ 
    "user:${var.service_owner}",
    "serviceAccount:${google_service_account.cloud_shedule_caller.email}"
    ]
}

# A Schedule to run the job on
resource "google_cloud_scheduler_job" "timer_trigger" {
  name             = "scheduled-cloud-run-job"
  project          = var.project_name
  description      = "Invoke a Cloud Run container on a schedule."
  schedule         = "*/8 * * * *"
  time_zone        = "Europe/Berlin"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 2
  }

  http_target {
    http_method = "POST"
    uri         = google_cloud_run_service.cloud_run_demo.status[0].url

    oidc_token {
      service_account_email = google_service_account.cloud_shedule_caller.email
    }
  }

}
# Cloud Build to update the cloud run job
resource "google_cloudbuild_trigger" "demo_cloud_build" {
  name        = "CloudRundDemo"
  project     = var.project_name
  description = "Triggers a new cloud run image to be build, when new code is published"
  github {
    owner = "fingineering"
    name  = "GCPCloudRunDemo"
    push {
      branch = "main"
    }
  }
  filename = "cloudbuild.yaml"

  substitutions = {
    "_REPO"       = var.container_name
    "_IMAGE_NAME" = var.container_name
    "_LOCATION"   = var.location
    "_SERVICE_NAME" = google_cloud_run_service.cloud_run_demo.name
  }
}

# IAM Binding for Cloud Run
