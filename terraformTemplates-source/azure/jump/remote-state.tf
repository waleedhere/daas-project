# terraform {
#   backend "s3" {
#     bucket = ""
#     key    = "ec2/bastion.tfstate"
#     region = ""
#     #encrypt = true
#     #kms_key_id = "alias/terraform"
#   }
# }

########################

terraform {
  backend "azurerm" {
    resource_group_name  = "StorageAccount-ResourceGroup"
    storage_account_name = "pocdaas123"
    container_name       = "tfstate2"
    key                  = "prod.terraform.tfstate"
    use_msi              = true
    subscription_id      = "a6f413aa-1a8e-41a8-b55b-9e20f8caffec"
    tenant_id            = "085121fe-7e3c-46d8-b86b-25ab5d024d63"
  }
}
