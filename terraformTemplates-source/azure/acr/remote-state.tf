terraform {
  backend "azurerm" {
    resource_group_name  = "Terraform-RG"
    storage_account_name = "pocdaas123"
    container_name       = "tfstate2"
    key                  = "poc.terraform.tfstate2"
    use_msi              = true
    subscription_id      = "a6f413aa-1a8e-41a8-b55b-9e20f8caffec"
    tenant_id            = "085121fe-7e3c-46d8-b86b-25ab5d024d63"
    access_key           = "VetmUH8UkU+gkmattU4XwQbDmkw/jAWrZYALx87CAVQBsyntwYtXW5KbrmsBlDjOolx5QgavMB7e+AStTEPRHQ=="
  }
}
