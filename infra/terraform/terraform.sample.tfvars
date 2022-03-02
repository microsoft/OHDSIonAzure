omop_password   = "<enter_omop_password>"
prefix          = "<enter_prefix>"
ad_admin_login_name  = "<enter-login-name>"
ad_admin_object_id   = "<enter-object-id>"

#### Tags
tags = {
  "OHDSI on Azure" = "OHDSI on Azure"
  "Environment"  = "dev"
}

#### Azure SQL
omop_db_size    = 100
omop_db_sku     = "GP_Gen5_8"

#### ACR
acr_sku_edition    = "Premium" # Network_rule_set_set can only be specified for a Premium Sku, the default is Standard sku and we are currently overriding this with Premium
broadsea_image     = "broadsea-webtools"
broadsea_image_tag = "latest"

#### Application Service Plan
asp_kind_edition = "Linux"
asp_sku_tier = "PremiumV2" #In the dedicated compute tiers (Basic, Standard, Premium, PremiumV2)
asp_sku_size = "P2V2"      # TODO: Check P2V2