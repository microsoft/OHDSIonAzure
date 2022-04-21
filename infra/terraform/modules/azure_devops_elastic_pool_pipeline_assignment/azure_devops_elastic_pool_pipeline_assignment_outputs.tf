output "azure_devops_elastic_pool_authorized_pipeline_ids" {
  # convert from csv
  value = ["${split(",", data.external.azure_devops_elastic_pool_pipeline_assignment.result.authorized_pipeline_ids)}"]
}