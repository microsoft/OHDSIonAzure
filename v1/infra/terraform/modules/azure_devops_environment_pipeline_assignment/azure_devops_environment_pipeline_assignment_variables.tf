# ---------------------------------------------------------------------------------------------------------------------
# Pass in a value for these parameters
# ---------------------------------------------------------------------------------------------------------------------



variable "authorized" {
  type        = bool
  description = "Authorize Environment for pipeline"
  default     = false
}

variable "ado_org_service_url" {
  description = "Azure DevOps Organization URL e.g. https://dev.azure.com/my-org"
}

variable "ado_project_name" {
  description = "Azure DevOps Project Name e.g. for the URL https://dev.azure.com/my-org/my-project you will provide `my-project`"
}

variable "ado_environment_id" {
  description = "Azure DevOps Environment Id"
}

variable "ado_pipeline_id" {
  description = "Azure DevOps Pipeline Id (also known as your Build Definition Id)"
}

variable "ado_pat" {
  description = "Azure DevOps PAT"
  sensitive   = true
}

