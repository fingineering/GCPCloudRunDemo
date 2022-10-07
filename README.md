# GCPCloudRunDemo

Es gibt Gelegenheiten, da ist eine oder mehrere serverlose Funktionen nicht
ausreichend, um einen Service darzustellen. Für diese Fälle gibt es auf der
Google Cloud Plattform Google Cloud Run. Cloud Run bietet zwei Möglichkeiten
Container auszuführen. Services und Jobs. In diesem Beispiel wird ein Google
Cloud Run Service mittels Terraform definiert, welcher auf Basis eines
Scheduler Jobs regelmäßig aufgerufen wird. Cloud Build wird dazu genutzt den
aktuellen Code auf den Service zu veröffentlichen.

## tl;dr

Mittel Terraform können alle notwendigen Komponenten erstellt werden, um einen
Cloud Run Services aus einem Github Repository kontinuierlich zu aktualisieren.
Als Beispiel wird ein stark vereinfachter Flask Webservice verwendet. Mittels
Cloud Scheduler wird dieser Service regelmäßig aufgerufen.

## Voraussetzungen

Bevor der Service aufgesetzt werden kann müssen einige Voraussetzungen erfüllt
sein. Es wird ein Google Cloud Project benötigt, sowie ein Github Account. Auf
dem Computer, welcher zur Entwicklung verwendet werden soll, müssen Terraform,
Google Cloud SDK, git, Docker und Python installiert sein. In diesem Beispiel
wird Python verwendet, es ist aber mit jeder Sprache möglich, mit der ein
WebServer erstellt werden kann.

- Ein Google Cloud Projekt kann bei [Google Cloud
  Plattform](https://cloud.google.com) erstellt werden. Es wird nur ein Google
  Account benötigt, Neukunden erhalten ein kostenloses Guthaben von 300€ für 90
  Tage.
- Wenn noch nicht vorhanden sollte ein kostenloser Github Account auf
  [Github](https://github.com) erstellt werden. Das Beispiel kann auch mittels
  Google Cloud Source Repositories umgesetzt werden. Als Alternative zu Cloud
  Build kann Github Actions eingesetzt werden.
- Terraform, Google Cloud SDK, Docker und Python müssen auf dem verwendeten
  Computer installiert werden, hierzu empfiehlt sich ein Paketmanager wie
  Homebrew oder Chocolatey. Linux Nutzer verwenden am besten den in ihrer
  Distribution mitgelieferten.
- Soll nichts installiert werden, dann kann auch die Google Cloud Shell
  verwendet werden, diese findet sich im in der [Cloud
  Console](https://console.cloud.google.com)

### APIs die in Google Cloud aktiviert werden müssen

Neben den Voraussetzungen zur Software müssen auf der Google Cloud Plattform
einige APIs aktiviert werden: 

- Cloud Run API
- Cloud Build API
- Artifact Registry API
- Cloud Scheduler API
- Cloud Logging API
- Identity and Access Management API

Die Cloud Run API wird benötigt um einen Cloud Run Service zu erstellen, die
Artifact Registry wird benötigt, um die Container Abbilder zu speichern. Die
Cloud Build API und die Identity and Access Management API werden benötigt, um
eine CI/CD Pipeline zu implementieren. Cloud Scheduler wird in diesem Beispiel
verwendet um den Service regelmäßig aufzurufen. Da alle Services via Terraform
erstellt und verwaltet werden, werden die APIs benötigt.

## Infrastruktur

Das Erstellen der Infrastruktur läuft in mehreren Schritten ab, nur wenn App Code und Container bereits vorhanden sind, kann der gesamte Prozess automatisiert werden. Für die Definition der Infrastruktur wird ein Ordner Infrastructure erstellt und darin die Dateien `main.tf`, `variables.tf`und terraform.tfvars`

```bash
mkdir Infrastructure
cd Infrastructure
touch main.tf
touch terraform.tfvars
```

Insgesamt werden vier Komponenten erstellt, das Artifact Registry Repository, ein Cloud Run Service, ein Cloud Build Trigger und ein Cloud Scheduler Job. Bevor die eigentliche Infrastruktur erzeugt werden kann müssen einige Service Accounts definiert werden. Ziel ist es, das jedes Asset eine eigene Identität zugewiesen werden kann. Daher werden drei Service Accounts erstellt, für den Run Service, den Build Trigger und den Scheduler Job.

```terraform
resource "google_service_account" "cloud_run_demo_sa" {
  project      = var.project_name
  account_id   = "cloudrundemosa"
  description  = "Running Cloud Run Scheduled Job to update data in BigQuery under this account"
  display_name = "Cloud Run Demo Service Account"
}
# Service account for scheduler to call the function
resource "google_service_account" "cloud_shedule_caller" {
  project      = var.project_name
  account_id   = "cloudscheduler"
  description  = "A service account to run the scheduler under an invoke the cloud run service"
  display_name = "Cloud Scheduler Demo User"
}

# Service Account to run the cloud build trigger
resource "google_service_account" "cloud_run_demo_builder" {
  project      = var.project_name
  account_id   = "cloudrundemobuilder"
  description  = "A service account to run the cloud build trigger"
  display_name = "Cloud Run Demo Build Trigger"
}
```

## Die Beispiel Flask Anwendung

```bash
docker run -e PORT=8080 -p 8080:8080 0b04ae2084ce
```

## Cloud Run Service aufsetzen

## Cloud Build Trigger erstellen



## Notizen

- Cloud Build muss roles/run.admin haben um auf den Cloud Run Service deployen zu dürfen.
- [Dokumentation des Deployments](https://cloud.google.com/build/docs/deploying-builds/deploy-cloud-run)

