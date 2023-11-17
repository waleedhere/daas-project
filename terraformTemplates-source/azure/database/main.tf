###########################################
# Database
###########################################
resource "azurerm_postgresql_server" "poc_db" {
  name                = var.database_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 640000

  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}