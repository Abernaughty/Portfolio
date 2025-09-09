terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "4.40.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_cosmosdb_account" "res-0" {
  access_key_metadata_writes_enabled           = true
  analytical_storage_enabled                   = false
  automatic_failover_enabled                   = true
  burst_capacity_enabled                       = false
  create_mode                                  = "Default"
  default_identity_type                        = "FirstPartyIdentity"
  free_tier_enabled                            = false
  ip_range_filter                              = []
  is_virtual_network_filter_enabled            = false
  kind                                         = "GlobalDocumentDB"
  local_authentication_disabled                = false
  location                                     = "centralus"
  minimal_tls_version                          = "Tls12"
  multiple_write_locations_enabled             = false
  name                                         = "pokemon-card-pricing-db"
  network_acl_bypass_for_azure_services        = false
  network_acl_bypass_ids                       = []
  offer_type                                   = "Standard"
  partition_merge_enabled                      = false
  primary_key                                  = "" # Masked sensitive attribute
  primary_mongodb_connection_string            = "" # Masked sensitive attribute
  primary_readonly_key                         = "" # Masked sensitive attribute
  primary_readonly_mongodb_connection_string   = "" # Masked sensitive attribute
  primary_readonly_sql_connection_string       = "" # Masked sensitive attribute
  primary_sql_connection_string                = "" # Masked sensitive attribute
  public_network_access_enabled                = true
  resource_group_name                          = "pokedata-rg"
  secondary_key                                = "" # Masked sensitive attribute
  secondary_mongodb_connection_string          = "" # Masked sensitive attribute
  secondary_readonly_key                       = "" # Masked sensitive attribute
  secondary_readonly_mongodb_connection_string = "" # Masked sensitive attribute
  secondary_readonly_sql_connection_string     = "" # Masked sensitive attribute
  secondary_sql_connection_string              = "" # Masked sensitive attribute
  tags = {
    defaultExperience       = "Core (SQL)"
    hidden-cosmos-mmspecial = ""
    hidden-workload-type    = "Development/Testing"
  }
  analytical_storage {
    schema_type = "WellDefined"
  }
  backup {
    interval_in_minutes = 0
    retention_in_hours  = 0
    storage_redundancy  = ""
    tier                = "Continuous7Days"
    type                = "Continuous"
  }
  capabilities {
    name = "EnableServerless"
  }
  capacity {
    total_throughput_limit = 4000
  }
  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
  geo_location {
    failover_priority = 0
    location          = "centralus"
    zone_redundant    = false
  }
}
