provider "azurerm" {
    features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
    name     = "example-resources"
    location = "East US"
}

resource "azurerm_virtual_network" "example" {
    name                = "example-network"
    resource_group_name = azurerm_resource_group.example.name
    location            = azurerm_resource_group.example.location
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
    name                 = "internal"
    resource_group_name  = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.example.name
    address_prefixes     = ["10.0.2.0/24"] 

    private_endpoint_network_policies_enabled = true
}

resource "azurerm_app_service_plan" "example" {
    name                = "example-appserviceplan"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name

    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "example" {
    name                = "example-appservice"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    app_service_plan_id = azurerm_app_service_plan.example.id
}

resource "azurerm_key_vault" "example" {
    name                        = "example-keyvault"
    location                    = azurerm_resource_group.example.location
    resource_group_name         = azurerm_resource_group.example.name
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    sku_name                    = "standard"
    purge_protection_enabled    = false
}

resource "azurerm_private_endpoint" "example" {
    name                = "example-endpoint"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    subnet_id           = azurerm_subnet.example.id

    private_service_connection {
        name                           = "example-connection"
        is_manual_connection           = false
        private_connection_resource_id = azurerm_key_vault.example.id
        subresource_names              = ["vault"]
    }
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "example"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_dns_a_record" "example" {
  name                = split(".", azurerm_key_vault.example.vault_uri)[0] # Extract the vault name from the URI
  zone_name           = azurerm_private_dns_zone.example.name
  resource_group_name = azurerm_resource_group.example.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.example.private_service_connection[0].private_ip_address]
}
