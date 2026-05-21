# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.app_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Frontend Subnet for Container Apps
resource "azurerm_subnet" "frontend_subnet" {
  name                 = "frontend-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Backend Subnet for PostgreSQL
resource "azurerm_subnet" "backend_subnet" {
  name                 = "backend-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  delegation {
    name = "fs"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Private DNS Zone for PostgreSQL
/*
resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "${var.app_name}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}
*/

/*
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "${var.app_name}-pdns-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}
*/

# PostgreSQL Database
resource "random_password" "postgres_password" {
  length  = 16
  special = true
}

/*
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "${var.app_name}-postgres"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "13"
  administrator_login    = "pgadmin"
  administrator_password = random_password.postgres_password.result
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
}
*/

# Log Analytics Workspace for Container Apps Environment
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.app_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Container App Environment
resource "azurerm_container_app_environment" "cae" {
  name                       = "${var.app_name}-cae"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  # Currently azurerm limits infrastructure_subnet_id for external environments, simplified here.
  # infrastructure_subnet_id   = azurerm_subnet.frontend_subnet.id
}

# Backend Container App
resource "azurerm_container_app" "backend" {
  name                         = "${var.app_name}-backend"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "backend"
      image  = var.docker_image
      cpu    = 0.5
      memory = "1.0Gi"
    }
  }

  ingress {
    external_enabled = false
    target_port      = var.port
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Frontend Container App
resource "azurerm_container_app" "frontend" {
  name                         = "${var.app_name}-frontend"
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "frontend"
      image  = var.docker_image
      cpu    = 0.5
      memory = "1.0Gi"
      env {
        name  = "BACKEND_URL"
        value = "http://${azurerm_container_app.backend.name}"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = var.port
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
