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
resource "azurerm_windows_function_app" "res-0" {
  app_settings                             = {}
  builtin_logging_enabled                  = false
  client_certificate_enabled               = false
  client_certificate_exclusion_paths       = ""
  client_certificate_mode                  = "Required"
  content_share_force_disabled             = false
  custom_domain_verification_id            = "" # Masked sensitive attribute
  daily_memory_time_quota                  = 0
  enabled                                  = true
  ftp_publish_basic_authentication_enabled = true
  functions_extension_version              = ""
  https_only                               = false
  key_vault_reference_identity_id          = "SystemAssigned"
  location                                 = "centralus"
  name                                     = "pokedata-func"
  public_network_access_enabled            = true
  resource_group_name                      = "pokedata-rg"
  service_plan_id                          = "/subscriptions/555b4cfa-ad2e-4c71-9433-620a59cf7616/resourceGroups/pokedata-rg/providers/Microsoft.Web/serverFarms/CentralUSPlan"
  site_credential                          = [] # Masked sensitive attribute
  storage_account_access_key               = "" # Masked sensitive attribute
  storage_account_name                     = ""
  storage_key_vault_secret_id              = ""
  storage_uses_managed_identity            = false
  tags = {
    "hidden-link: /app-insights-conn-string"         = "InstrumentationKey=aa5b1825-f0a5-4ed1-ae2e-01ae2e133cb2;IngestionEndpoint=https://centralus-2.in.applicationinsights.azure.com/;LiveEndpoint=https://centralus.livediagnostics.monitor.azure.com/;ApplicationId=c42995c5-4b86-426e-9d2c-faecbbda7c4e"
    "hidden-link: /app-insights-instrumentation-key" = "aa5b1825-f0a5-4ed1-ae2e-01ae2e133cb2"
    "hidden-link: /app-insights-resource-id"         = "/subscriptions/555b4cfa-ad2e-4c71-9433-620a59cf7616/resourceGroups/pokedata-rg/providers/microsoft.insights/components/pokedata-func"
  }
  virtual_network_backup_restore_enabled         = false
  virtual_network_subnet_id                      = ""
  vnet_image_pull_enabled                        = false
  webdeploy_publish_basic_authentication_enabled = true
  zip_deploy_file                                = ""
  site_config {
    always_on                              = false
    api_definition_url                     = ""
    api_management_api_id                  = ""
    app_command_line                       = ""
    app_scale_limit                        = 200
    application_insights_connection_string = "" # Masked sensitive attribute
    application_insights_key               = "" # Masked sensitive attribute
    default_documents                      = ["Default.htm", "Default.html", "Default.asp", "index.htm", "index.html", "iisstart.htm", "default.aspx", "index.php", "hostingstart.html"]
    elastic_instance_minimum               = 1
    ftps_state                             = "FtpsOnly"
    health_check_eviction_time_in_min      = 0
    health_check_path                      = ""
    http2_enabled                          = true
    ip_restriction_default_action          = ""
    load_balancing_mode                    = "LeastRequests"
    managed_pipeline_mode                  = "Integrated"
    minimum_tls_version                    = "1.2"
    pre_warmed_instance_count              = 0
    remote_debugging_enabled               = false
    remote_debugging_version               = ""
    runtime_scale_monitoring_enabled       = false
    scm_ip_restriction_default_action      = ""
    scm_minimum_tls_version                = "1.2"
    scm_use_main_ip_restriction            = false
    use_32_bit_worker                      = true
    vnet_route_all_enabled                 = false
    websockets_enabled                     = false
    worker_count                           = 1
    application_stack {
      node_version = "~22"
    }
    cors {
      allowed_origins     = ["http://localhost:3000", "https://calm-mud-07a7f7a10.6.azurestaticapps.net", "https://maber-apim-test.azure-api.net", "https://pokedata.maber.io", "https://portal.azure.com"]
      support_credentials = false
    }
  }
}
