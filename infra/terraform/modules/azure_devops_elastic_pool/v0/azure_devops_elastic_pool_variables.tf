# ---------------------------------------------------------------------------------------------------------------------
# Pass in a value for these parameters
# ---------------------------------------------------------------------------------------------------------------------

variable "ado_agent_pool_name" {
  description = "Azure DevOps agent pool name"
}

variable "ado_vmss_resource_id" {
  description = "Azure VMSS Resource ID (e.g. '/subscriptions/<my-subscription-id>/resourceGroups/<my-rg>/providers/Microsoft.Compute/virtualMachineScaleSets/<my-vmss-agent>') to back the agent pool"
}

variable "ado_service_endpoint_id" {
  description = "Azure DevOps Service Endpoint Id to use with your agent pool to connect to your Azure VMSS"
}

variable "ado_vmss_max_capacity" {
  type        = number
  description = "Max Capacity for your Azure VMSS Agent Pool"
  default     = 2
}

variable "ado_vmss_desired_size" {
  type        = number
  description = "Desired Size for your Azure VMSS Agent Pool"
  default     = 1
}

variable "ado_vmss_desired_idle" {
  type        = number
  description = "Desired number of idle agents for your Azure VMSS Agent Pool"
  default     = 1
}

variable "ado_vmss_time_to_live_minutes" {
  type        = number
  description = "Tiem to live in minutes for your agents for your Azure VMSS Agent Pool"
  default     = 30
}

variable "ado_vmss_recycle_after_each_use" {
  type        = bool
  description = "Recycle each agent instance after use in your Azure VMSS Agent Pool"
  default     = false
}

variable "ado_vmss_os_type" {
  type        = string
  description = "Azure VMSS ostype (can specify `linux`, `windows`)"

  validation {
    condition     = contains(["linux", "windows"], var.ado_vmss_os_type)
    error_message = "Valid values for var: pool_options ado_vmss_os_type (linux, windows)."
  }
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