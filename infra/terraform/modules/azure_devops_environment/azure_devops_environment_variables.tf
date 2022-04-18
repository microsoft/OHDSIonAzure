# ---------------------------------------------------------------------------------------------------------------------
# Pass in a value for these parameters
# ---------------------------------------------------------------------------------------------------------------------

variable "environment_name" {
  description = "Azure DevOps environment name"
}

variable "ado_org_service_url" {
  description = "Azure DevOps Organization URL e.g. https://dev.azure.com/my-org"
}

variable "ado_pat" {
  description = "Azure DevOps PAT"
  sensitive   = true
}

variable "ado_project_id" {
  description = "Azure DevOps Project ID"
}