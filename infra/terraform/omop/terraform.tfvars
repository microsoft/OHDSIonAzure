prefix                           = "sharing"
environment                      = "dev"
aad_admin_login_name             = "<filled-in-by-variable-group>"
aad_admin_object_id              = "<filled-in-by-variable-group>"
aad_directory_readers_login_name = "<filled-in-by-variable-group>"
aad_directory_readers_object_id  = "<filled-in-by-variable-group>"

#### Tags
tags = {
  "Deployment"  = "OHDSI on Azure"
  "Environment" = "dev"
}

#### Azure SQL
omop_db_size = 100
omop_db_sku  = "GP_Gen5_8"

#### ACR
acr_sku_edition = "Premium" # Network_rule_set_set can only be specified for a Premium Sku, the default is Standard sku and we are currently overriding this with Premium

#### Application Service Plan
asp_kind_edition = "Linux"
asp_sku_tier     = "PremiumV2" #In the dedicated compute tiers (Basic, Standard, Premium, PremiumV2)
asp_sku_size     = "P2V2"      # TODO: Check P2V2