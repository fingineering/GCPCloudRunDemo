variable "project_name" {
  type = string
  sensitive = true
}

variable "container_name" {
  type = string
}

variable "location" {
  type = string
  default = "europe-west3"
}

variable "RunJobName" {
  type = string
  default = "cloud-run-demo"
}

variable "service_owner" {
  type = string
  sensitive = true
}