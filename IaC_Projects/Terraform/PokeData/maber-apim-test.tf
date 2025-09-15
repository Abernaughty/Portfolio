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
resource "azurerm_api_management" "res-0" {
  client_certificate_enabled    = false
  gateway_disabled              = false
  location                      = "centralus"
  min_api_version               = ""
  name                          = "maber-apim-test"
  notification_sender_email     = "apimgmt-noreply@mail.windowsazure.com"
  public_ip_address_id          = ""
  public_network_access_enabled = true
  publisher_email               = "mabernathy87@gmail.com"
  publisher_name                = "maber"
  resource_group_name           = "maber-testing"
  sku_name                      = "Consumption_0"
  tags                          = {}
  virtual_network_type          = "None"
  zones                         = []
  hostname_configuration {
    proxy {
      certificate                     = "" # Masked sensitive attribute
      certificate_password            = "" # Masked sensitive attribute
      default_ssl_binding             = true
      host_name                       = "maber-apim-test.azure-api.net"
      key_vault_certificate_id        = ""
      key_vault_id                    = ""
      negotiate_client_certificate    = false
      ssl_keyvault_identity_client_id = ""
    }
  }
  identity {
    identity_ids = []
    type         = "SystemAssigned"
  }
  protocols {
    enable_http2  = false
    http2_enabled = false
  }
  security {
    backend_ssl30_enabled                               = false
    backend_tls10_enabled                               = false
    backend_tls11_enabled                               = false
    enable_backend_ssl30                                = false
    enable_backend_tls10                                = false
    enable_backend_tls11                                = false
    enable_frontend_ssl30                               = false
    enable_frontend_tls10                               = false
    enable_frontend_tls11                               = false
    frontend_ssl30_enabled                              = false
    frontend_tls10_enabled                              = false
    frontend_tls11_enabled                              = false
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = false
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = false
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = false
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = false
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = false
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = false
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = false
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = false
    triple_des_ciphers_enabled                          = false
  }
}
